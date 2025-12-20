#!/bin/bash
# Auto-lock screen after 3 minutes of inactivity
# Does NOT lock if:
# - Video is playing (fullscreen detection)
# - Audio is playing (pulseaudio sink check)
# - Specific apps are focused (YouTube, Jellyfin, mpv, vlc, etc.)

LOCK_SCRIPT="$HOME/.config/dwm/scripts/lock.sh"
IDLE_TIME=180  # 3 minutes in seconds

# Check if audio is playing
is_audio_playing() {
    # Check PulseAudio/PipeWire for running audio streams
    if command -v pactl &>/dev/null; then
        pactl list sink-inputs 2>/dev/null | grep -q "state: RUNNING" && return 0
    fi
    # Check PipeWire
    if command -v pw-cli &>/dev/null; then
        pw-cli ls Node 2>/dev/null | grep -q "running" && return 0
    fi
    return 1
}

# Check if video is playing (fullscreen window check)
is_fullscreen() {
    # Get active window
    local active_win=$(xdotool getactivewindow 2>/dev/null)
    [[ -z "$active_win" ]] && return 1

    # Check if window is fullscreen
    xprop -id "$active_win" 2>/dev/null | grep -q "_NET_WM_STATE_FULLSCREEN" && return 0
    return 1
}

# Check if a video app is running and focused
is_video_app_active() {
    local active_win=$(xdotool getactivewindow 2>/dev/null)
    [[ -z "$active_win" ]] && return 1

    local win_class=$(xprop -id "$active_win" WM_CLASS 2>/dev/null | cut -d'"' -f4 | tr '[:upper:]' '[:lower:]')
    local win_name=$(xdotool getwindowname "$active_win" 2>/dev/null | tr '[:upper:]' '[:lower:]')

    # Check for video players and streaming sites
    local video_apps="mpv vlc celluloid totem firefox chromium chrome brave youtube jellyfin netflix plex"
    local video_keywords="youtube jellyfin netflix plex twitch video watch movie"

    for app in $video_apps; do
        [[ "$win_class" == *"$app"* ]] && return 0
    done

    # Check window title for video-related keywords
    for keyword in $video_keywords; do
        [[ "$win_name" == *"$keyword"* ]] && return 0
    done

    return 1
}

# Check if we should inhibit lock
should_inhibit_lock() {
    # Don't lock if audio is playing
    is_audio_playing && return 0

    # Don't lock if fullscreen (likely video)
    is_fullscreen && return 0

    # Don't lock if video app is active
    is_video_app_active && return 0

    return 1
}

# Use xidlehook if available (preferred - more features)
if command -v xidlehook &>/dev/null; then
    exec xidlehook \
        --not-when-fullscreen \
        --not-when-audio \
        --timer $IDLE_TIME "$LOCK_SCRIPT" ""
fi

# Fallback to xautolock with custom inhibit check
if command -v xautolock &>/dev/null; then
    # Kill any existing xautolock
    pkill -x xautolock 2>/dev/null

    # Start xautolock with our lock script
    # We use a wrapper to check for video before locking
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
    # Get idle time in milliseconds
    idle_ms=$(xprintidle 2>/dev/null || echo 0)
    idle_sec=$((idle_ms / 1000))

    if (( idle_sec >= IDLE_TIME )); then
        if ! should_inhibit_lock; then
            "$LOCK_SCRIPT"
        fi
    fi

    sleep 10
done
