#!/usr/bin/env bash
# Optional application; kept separate from normal chezmoi deployment.
set -euo pipefail

STRIX_VERSION=v0.3.6
STRIX_COMMIT=c10e82c02373861ee3c2987f282b8cdc509ac8a3
STRIX_REPOSITORY=https://github.com/Dodzux/Strix-Core.git

usage() {
    cat <<EOF
Usage: $(basename "$0") [--help]

Build and install Strix Core $STRIX_VERSION from its verified source revision.
Requires Arch/CachyOS with base-devel and git. Run as your normal user;
makepkg asks for authentication when installing dependencies and the package.
Installation does not start the app, enable autostart or change hardware.
EOF
}

if (( $# )); then
    case "$1" in
        -h|--help) usage; exit 0 ;;
        *) usage >&2; exit 2 ;;
    esac
fi
if (( EUID == 0 )); then
    echo 'Run this installer as your normal user, not with sudo.' >&2
    exit 1
fi
for dependency in git pacman makepkg fakeroot; do
    if ! command -v "$dependency" >/dev/null 2>&1; then
        echo 'Missing build tools. Install them with: sudo pacman -S --needed base-devel git' >&2
        exit 1
    fi
done

build_dir=$(mktemp -d "${TMPDIR:-/tmp}/hyprdodz-strix-core.XXXXXX")
trap 'rm -rf -- "$build_dir"' EXIT

printf 'Fetching Strix Core %s (GPL-3.0-only)...\n' "$STRIX_VERSION"
git -c advice.detachedHead=false clone --depth 1 --single-branch \
    --branch "$STRIX_VERSION" "$STRIX_REPOSITORY" "$build_dir/source"
if [[ $(git -C "$build_dir/source" rev-parse HEAD) != "$STRIX_COMMIT" ]]; then
    echo 'Strix Core source does not match the reviewed release; installation stopped.' >&2
    exit 1
fi
(
    cd "$build_dir/source/packaging"
    makepkg --syncdeps --install
)
printf '\nInstalled Strix Core %s. Launch it with: strix-core\n' "$STRIX_VERSION"
