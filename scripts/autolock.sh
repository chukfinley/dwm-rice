#!/bin/bash
# Auto-lock screen after 3 minutes of inactivity
# Does NOT lock if watching video (YouTube, Jellyfin, Netflix, etc.)
# DOES lock even if Spotify/music is playing

LOCK_SCRIPT="$HOME/.config/dwm/scripts/lock.sh"
IDLE_TIME=180  # 3 minutes in seconds

# Check if watching video content
is_watching_video() {
    # Check all visible windows for video sites
    for win in $(xdotool search --onlyvisible --name "" 2>/dev/null); do
        local win_name=$(xdotool getwindowname "$win" 2>/dev/null | tr '[:upper:]' '[:lower:]')

        if [[ "$win_name" == *"youtube"* ]] || \
           [[ "$win_name" == *"jellyfin"* ]] || \
           [[ "$win_name" == *"netflix"* ]] || \
           [[ "$win_name" == *"plex"* ]] || \
           [[ "$win_name" == *"twitch"* ]] || \
           [[ "$win_name" == *"prime video"* ]] || \
           [[ "$win_name" == *"disney+"* ]]; then
            return 0
        fi
    done

    # Check for video players
    pgrep -x "mpv|vlc|celluloid|totem" >/dev/null 2>&1 && return 0

    return 1
}

# Use xidlehook if available (preferred - more features)
if command -v xidlehook &>/dev/null; then
    # Note: removed --not-when-audio so Spotify won't block lock
    exec xidlehook \
        --not-when-fullscreen \
        --timer $IDLE_TIME "$HOME/.config/dwm/scripts/autolock-check.sh" ""
fi

# Fallback to xautolock with custom inhibit check
if command -v xautolock &>/dev/null; then
    # Kill any existing xautolock
    pkill -x xautolock 2>/dev/null

    # Start xautolock with our lock script
    # autolock-check.sh handles video detection
    exec xautolock \
        -time 3 \
        -locker "$HOME/.config/dwm/scripts/autolock-check.sh" \
        -detectsleep \
        -notify 30 \
        -notifier "notify-send 'Auto-lock' 'Locking in 30 seconds...'" &
    exit 0
fi

# Manual fallback using a loop (if no xidlehook/xautolock)
echo "Warning: xidlehook or xautolock not found, using manual idle detection"
while true; do
    idle_ms=$(xprintidle 2>/dev/null || echo 0)
    idle_sec=$((idle_ms / 1000))

    if (( idle_sec >= IDLE_TIME )); then
        if ! is_watching_video; then
            "$LOCK_SCRIPT"
        fi
    fi

    sleep 10
done
