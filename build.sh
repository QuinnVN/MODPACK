#!/usr/bin/env bash
set -euo pipefail

root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd -- "$root/pack"

if [[ ! -f mods/voxy-0.6.0.jar ]]; then
    printf '%s\n' 'Restore pack/mods/voxy-0.6.0.jar from the source PrismLauncher instance before building.' >&2
    exit 1
fi

packwiz_name=packwiz
case "$OSTYPE" in
    msys*|cygwin*) packwiz_name=packwiz.exe ;;
esac

packwiz="../.tools/bin/$packwiz_name"
if [[ ! -f "$packwiz" || ! -x "$packwiz" ]]; then
    packwiz=packwiz
    if ! command -v "$packwiz" >/dev/null 2>&1; then
        printf 'Install packwiz on PATH or place an executable %s in .tools/bin/.\n' "$packwiz_name" >&2
        exit 1
    fi
fi

"$packwiz" list
"$packwiz" refresh

mkdir -p ../dist
output=../dist/MODPACK-Full-0.1.0-snapshot.mrpack
temporary_dir="$(mktemp -d ../dist/.build.XXXXXXXX)"
temporary_pack="$temporary_dir/MODPACK-Full-0.1.0-snapshot.mrpack"
trap 'rm -f -- "$temporary_pack"; rmdir -- "$temporary_dir"' EXIT

"$packwiz" --cache ../.tools/packwiz-cache modrinth export -o "$temporary_pack"
mv -f -- "$temporary_pack" "$output"
printf '%s\n' 'Built dist/MODPACK-Full-0.1.0-snapshot.mrpack'
