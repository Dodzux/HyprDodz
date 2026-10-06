#!/usr/bin/env bash
# Apply only the newest requested wallpaper; sync after awww accepts it.
set -u
script_dir=$(cd -- "$(dirname -- "$0")" && pwd)
wallpaper_dir="$HOME/Pictures/Wallpapers"
image="${1:-}"
if [[ -z "$image" ]]; then
    current=$(awww query 2>/dev/null | sed -n 's/.*currently displaying: image: //p' | head -1)
    image=$(find "$wallpaper_dir" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' -o -iname '*.gif' \) ! -path "${current:-/none}" 2>/dev/null | shuf -n 1)
fi
[[ -f "$image" ]] || { notify-send Wallpaper "No wallpaper found in $wallpaper_dir" 2>/dev/null; exit 1; }
monitors=$(hyprctl monitors -j 2>/dev/null)
outputs=$(jq -r '[.[] | select(.disabled != true) | .name] | join(",")' <<< "$monitors" 2>/dev/null)
[[ -n "$outputs" && "$outputs" != null ]] || { notify-send Wallpaper 'Could not find an active display' 2>/dev/null; exit 1; }
fps=$(jq '[.[] | select(.disabled != true) | .refreshRate] | max | floor' <<< "$monitors" 2>/dev/null)
[[ "$fps" =~ ^[0-9]+$ ]] || fps=60
state="${XDG_RUNTIME_DIR:-/tmp}/wallpaper-transition"
exec 8> "$state.request.lock"
flock 8
request=$(python3 -c 'import os,time; print(str(os.getpid())+"-"+str(time.monotonic_ns()))')
printf '%s' "$request" > "$state.want.$$"
mv -- "$state.want.$$" "$state.want"
flock -u 8
exec 8>&-
exec 9> "$state.apply.lock"
flock 9
[[ "$(cat "$state.want")" == "$request" ]] || exit 0
log_dir="${XDG_STATE_HOME:-$HOME/.local/state}/hypr"
mkdir -p -- "$log_dir"
# Analyze during image loading, without applying an unaccepted wallpaper.
python3 "$script_dir/sync_border.py" --warm-cache "$image" >> "$log_dir/accent-sync.log" 2>&1 9>&- &
if ! awww img "$image" --outputs "$outputs" --transition-type random --transition-fps "$fps" --transition-duration 0.6 --transition-step 90; then
    notify-send Wallpaper 'Wallpaper update failed; kept the current accent' 2>/dev/null
    exit 1
fi
[[ "$(cat "$state.want")" == "$request" ]] || exit 0
# Claim here, rather than inside a delayed background child. Reload/startup
# requests that observed the old wallpaper are now superseded.
token=$(python3 "$script_dir/sync_border.py" --claim-token) || exit 1
python3 "$script_dir/sync_border.py" --token "$token" "$image" >> "$log_dir/accent-sync.log" 2>&1 9>&- &
flock -u 9
exec 9>&-
