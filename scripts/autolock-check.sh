#!/bin/bash
# Called by xautolock - checks if we should lock or inhibit

LOCK_SCRIPT="$HOME/.config/dwm/scripts/lock.sh"

# Check if audio is playing
is_audio_playing() {
    if command -v pactl &>/dev/null; then
        pactl list sink-inputs 2>/dev/null | grep -q "state: RUNNING" && return 0
    fi
    if command -v pw-cli &>/dev/null; then
        pw-cli ls Node 2>/dev/null | grep -q "running" && return 0
    fi
    return 1
}

# Check if fullscreen
is_fullscreen() {
    local active_win=$(xdotool getactivewindow 2>/dev/null)
    [[ -z "$active_win" ]] && return 1
    xprop -id "$active_win" 2>/dev/null | grep -q "_NET_WM_STATE_FULLSCREEN" && return 0
    return 1
}

# If audio playing or fullscreen, don't lock
if is_audio_playing || is_fullscreen; then
    exit 0
fi

# Lock
exec "$LOCK_SCRIPT"
