#!/bin/bash
# Called by xautolock - checks if we should lock or inhibit
# Inhibits lock ONLY for video content (YouTube, Jellyfin, etc.)
# Does NOT inhibit for audio-only (Spotify, music)

LOCK_SCRIPT="$HOME/.config/dwm/scripts/lock.sh"

# Check if watching video (YouTube, Jellyfin, etc.)
is_watching_video() {
    # Get all visible windows and check their titles
    for win in $(xdotool search --onlyvisible --name "" 2>/dev/null); do
        local win_name=$(xdotool getwindowname "$win" 2>/dev/null | tr '[:upper:]' '[:lower:]')

        # Check for video sites/apps in window title
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

    # Check for video players (mpv, vlc, etc.)
    pgrep -x "mpv|vlc|celluloid|totem" >/dev/null 2>&1 && return 0

    return 1
}

# If watching video, don't lock
if is_watching_video; then
    exit 0
fi

# Lock
exec "$LOCK_SCRIPT"
