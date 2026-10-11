#!/bin/sh
# F11/F12: pressing either key during selection cancels the active selector.
set -eu

mode=${1:-}
case "$mode" in
    copy|annotate) ;;
    *) echo "Usage: $0 copy|annotate" >&2; exit 2 ;;
esac

if pkill -x slurp; then
    exit 0
fi

geometry=$(slurp) || exit 0
[ -n "$geometry" ] || exit 0

# Let the compositor process the selector's removal before requesting a frame.
sleep 0.2

image=$(mktemp "${TMPDIR:-/tmp}/screenshot-region.XXXXXX.png")
trap 'rm -f "$image"' EXIT
trap 'exit 130' INT
trap 'exit 143' TERM HUP
# A stuck screencopy client must not remain connected indefinitely.
timeout --kill-after=2s 10s grim -g "$geometry" "$image"

case "$mode" in
    copy)
        wl-copy -t image/png < "$image"
        ;;
    annotate)
        output_dir="$HOME/Pictures/Screenshots"
        mkdir -p "$output_dir"
        satty --filename "$image" \
            --output-filename "$output_dir/$(date +%Y-%m-%d_%H-%M-%S).png"
        ;;
esac
