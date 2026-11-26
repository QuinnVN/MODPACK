#!/usr/bin/env bash
set -euo pipefail

root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source_pack="$root/pack"

packwiz_name=packwiz
case "$OSTYPE" in
    msys*|cygwin*) packwiz_name=packwiz.exe ;;
esac

packwiz="$root/.tools/bin/$packwiz_name"
if [[ ! -f "$packwiz" || ! -x "$packwiz" ]]; then
    packwiz=packwiz
    if ! command -v "$packwiz" >/dev/null 2>&1; then
        printf 'Install packwiz on PATH or place an executable %s in .tools/bin/.\n' "$packwiz_name" >&2
        exit 1
    fi
fi

if ! command -v python3 >/dev/null 2>&1; then
    printf '%s\n' 'Install Python 3 on PATH to combine the client and server exports.' >&2
    exit 1
fi

build_timestamp="$(date +%s)"
filename="MODPACK-$build_timestamp.mrpack"
cache="$root/.tools/packwiz-cache"
mkdir -p -- "$root/dist"
dist="$(cd -- "$root/dist" && pwd -P)"
work="$(mktemp -d "$dist/.build.XXXXXXXX")"
cleanup() {
    if [[ "${work%/*}" == "$dist" && "${work##*/}" == .build.* ]]; then
        rm -rf -- "$work"
    fi
}
trap cleanup EXIT

baseline="$work/full"
cp -R -P -- "$source_pack" "$baseline"
shopt -s dotglob
entry_pattern='^(mods|shaderpacks)/[a-zA-Z0-9_.+ -]+\.(pw\.toml|jar|zip)$'
for profile in lite server; do
    stage="$work/$profile"
    mkdir -p -- "$stage/mods" "$stage/shaderpacks"
    for path in "$baseline"/*; do
        case "${path##*/}" in mods|shaderpacks) continue ;; esac
        cp -R -P -- "$path" "$stage/"
    done

    while IFS= read -r line || [[ -n "$line" ]]; do
        read -r entry <<< "${line%$'\r'}"
        [[ -z "$entry" || "$entry" == \#* ]] && continue
        if [[ ! "$entry" =~ $entry_pattern ]]; then
            printf 'Invalid entry in profiles/%s/allow.txt: %s\n' "$profile" "$entry" >&2
            exit 1
        fi
        if [[ ! -f "$baseline/$entry" || -e "$stage/$entry" ]]; then
            printf 'Missing or duplicate entry in profiles/%s/allow.txt: %s\n' "$profile" "$entry" >&2
            exit 1
        fi
        cp -P -- "$baseline/$entry" "$stage/$entry"
    done < "$root/profiles/$profile/allow.txt"
done
mkdir -p -- "$work/lite/configureddefaults"
cp -- "$root/profiles/lite/configureddefaults/options.txt" "$work/lite/configureddefaults/"

for profile in full lite server; do
    archive="$work/$profile.mrpack"
    (
        cd -- "$work/$profile"
        "$packwiz" refresh
        "$packwiz" --cache "$cache" modrinth export -o "$archive"
    )
    if [[ ! -f "$archive" ]]; then
        printf 'packwiz did not export %s.mrpack.\n' "$profile" >&2
        exit 1
    fi
done

python3 "$root/merge-mrpack.py" "$work/full.mrpack" "$work/lite.mrpack" "$work/server.mrpack" "$work/$filename"

mv -f -- "$work/$filename" "$dist/$filename"
printf 'Built dist/%s\n' "$filename"
