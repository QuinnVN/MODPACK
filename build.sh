#!/usr/bin/env bash
set -euo pipefail

root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source_pack="$root/pack"

server_revision=
if [[ $# -ne 0 ]]; then
    if [[ $# -ne 2 || $1 != --server-revision || ! $2 =~ ^([2-9]|[1-9][0-9]+)$ ]]; then
        printf 'Usage: bash build.sh [--server-revision N] (N must be at least 2)\n' >&2
        exit 1
    fi
    server_revision=$2
fi

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
    printf '%s\n' 'Install Python 3 on PATH to package the Packwiz exports.' >&2
    exit 1
fi

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

baseline="$source_pack"
profiles=(server)
if [[ -z "$server_revision" ]]; then
    baseline="$work/full"
    cp -R -P -- "$source_pack" "$baseline"
    profiles=(full lite server)
fi
shopt -s dotglob
entry_pattern='^(mods|shaderpacks)/[a-zA-Z0-9_.+ -]+\.(pw\.toml|jar|zip)$'
for profile in "${profiles[@]}"; do
    [[ "$profile" == full ]] && continue
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
if [[ -z "$server_revision" ]]; then
    mkdir -p -- "$work/lite/configureddefaults"
    cp -- "$root/profiles/lite/configureddefaults/options.txt" "$work/lite/configureddefaults/"
fi

for profile in "${profiles[@]}"; do
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

if [[ -n "$server_revision" ]]; then
    python3 "$root/package-mrpack.py" server "$work/server.mrpack" "$work" "$server_revision"
else
    python3 "$root/package-mrpack.py" both "$work/full.mrpack" "$work/lite.mrpack" "$work/server.mrpack" "$work"
fi

for pack in "$work"/MODPACK-*.mrpack; do
    mv -f -- "$pack" "$dist/${pack##*/}"
    printf 'Built dist/%s\n' "${pack##*/}"
done
