#!/usr/bin/env bash
# One temporary worker finishes each transition and drains the newest request.
set -u
script_dir=$(cd -- "$(dirname -- "$0")" && pwd)
wallpaper_dir="$HOME/Pictures/Wallpapers"
image="${1:-}"
[[ -z "$image" || -f "$image" ]] || exit 1
state="${XDG_RUNTIME_DIR:-/tmp}/wallpaper-transition"
request="$$-$EPOCHREALTIME"

# Register before querying/decoding images. Busy callers leave their request
# and exit instead of building a queue of blocked launcher processes.
exec 8> "$state.request.lock"
flock 8
printf '%s\0%s\0' "$request" "$image" > "$state.want.$$"
mv -- "$state.want.$$" "$state.want"
exec 9> "$state.apply.lock"
if ! flock -n 9; then
    exit 0
fi
flock -u 8

log_dir="${XDG_STATE_HOME:-$HOME/.local/state}/hypr"
mkdir -p -- "$log_dir"
accepted=""
synced=""
is_current() {
    local latest
    IFS= read -r -d '' latest < "$state.want"
    [[ "$latest" == "$request" ]]
}
wallpaper_error() {
    printf '%(%F %T)T wallpaper: %s\n' -1 "$1" >> "$log_dir/accent-sync.log"
    if is_current; then
        notify-send Wallpaper "$1" 2>/dev/null || :
    fi
}
sync_accepted() {
    [[ -n "$accepted" && "$accepted" != "$synced" ]] || return 0
    local token
    token=$(python3 "$script_dir/sync_border.py" --claim-token) || return 1
    python3 "$script_dir/sync_border.py" --token "$token" "$accepted" >> "$log_dir/accent-sync.log" 2>&1 8>&- 9>&- &
    synced="$accepted"
}
apply_wallpaper() {
    local current monitors outputs fps
    current=$(timeout -k 1s 2s awww query 2>/dev/null | sed -n 's/.*currently displaying: image: //p' | head -1)
    if [[ -z "$image" ]]; then
        # Choose when applying, so a rapid request cannot choose the image
        # that the preceding transition has just installed.
        IFS= read -r -d '' image < <(find "$wallpaper_dir" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' -o -iname '*.gif' \) ! -path "${current:-/none}" -print0 2>/dev/null | shuf -z -n 1) || :
    fi
    is_current || return
    [[ -f "$image" ]] || { wallpaper_error "No other wallpaper found in $wallpaper_dir"; return; }
    monitors=$(timeout -k 1s 2s hyprctl monitors -j 2>/dev/null)
    outputs=$(jq -r '[.[] | select(.disabled != true) | .name] | join(",")' <<< "$monitors" 2>/dev/null)
    [[ -n "$outputs" && "$outputs" != null ]] || { wallpaper_error 'Could not find an active display'; return; }
    fps=$(jq '[.[] | select(.disabled != true) | .refreshRate] | max | floor' <<< "$monitors" 2>/dev/null)
    [[ "$fps" =~ ^[0-9]+$ ]] || fps=60
    is_current || return
    # Analyze while awww loads; background children never inherit our locks.
    python3 "$script_dir/sync_border.py" --warm-cache "$image" >> "$log_dir/accent-sync.log" 2>&1 8>&- 9>&- &
    if timeout -k 1s 15s awww img "$image" --outputs "$outputs" --transition-type random --transition-fps "$fps" --transition-duration 0.75 --transition-step 90 >> "$log_dir/accent-sync.log" 2>&1; then
        accepted="$image"
        python3 "$HOME/.config/quickshell/scripts/desktop_extras.py" record-wallpaper --path "$image" --previous "${current:-}" >> "$log_dir/accent-sync.log" 2>&1
        # Keep normal accent/RGB updates immediate, alongside the transition.
        flock 8
        if is_current; then
            sync_accepted
        fi
        flock -u 8
        # awww acknowledges before its transition finishes. Avoid interrupting
        # its Wayland buffers; incoming requests coalesce during this pause.
        sleep 0.80
    else
        wallpaper_error 'Wallpaper update failed; kept the last accepted wallpaper accent'
    fi
}

while :; do
    exec 7< "$state.want"
    IFS= read -r -d '' request <&7
    IFS= read -r -d '' image <&7
    exec 7<&-
    apply_wallpaper
    flock 8
    if ! is_current; then
        flock -u 8
        continue
    fi
    # Finish/check and release while holding the registration lock, so a
    # request arriving as we exit either gets drained or starts a new worker.
    # Sync the last accepted image even if a newer image failed to load.
    sync_accepted || exit 1
    flock -u 9
    exec 9>&-
    flock -u 8
    exec 8>&-
    exit 0
done
