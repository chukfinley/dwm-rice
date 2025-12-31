#!/bin/bash
# Auto-detect dock/monitor connection and configure displays
# Laptop screen stays on, external monitors go above it

LAPTOP="eDP-1"

# Get connected external monitors
get_external_monitors() {
    xrandr --query | grep " connected" | grep -v "$LAPTOP" | cut -d' ' -f1
}

# Check if specific monitors are connected
is_connected() {
    xrandr --query | grep "^$1 connected" >/dev/null 2>&1
}

# Configure displays based on what's connected
configure_displays() {
    local externals=($(get_external_monitors))
    local count=${#externals[@]}

    if (( count == 0 )); then
        # No external monitors - just laptop
        xrandr --output "$LAPTOP" --auto --primary
        echo "Laptop only mode"
    elif is_connected "DP-3-1" && is_connected "DP-3-2"; then
        # Dual ultrawide dock setup - specific positions for proper alignment
        xrandr --output "$LAPTOP" --primary --mode 1920x1080 --pos 277x1080 --rotate normal \
               --output HDMI-1 --off --output DP-1 --off --output DP-2 --off \
               --output DP-3 --off --output DP-4 --off \
               --output DP-3-1 --mode 2560x1080 --pos 0x0 --rotate normal \
               --output DP-3-2 --mode 2560x1080 --pos 2560x0 --rotate normal \
               --output DP-3-3 --off
        echo "Dual ultrawide dock: DP-3-1 + DP-3-2 above laptop (centered)"
    elif (( count == 1 )); then
        # One external monitor above laptop
        xrandr --output "$LAPTOP" --auto --primary \
               --output "${externals[0]}" --auto --above "$LAPTOP"
        echo "Single external: ${externals[0]} above laptop"
    else
        # Multiple externals - first one above laptop, rest to the right
        xrandr --output "$LAPTOP" --auto --primary
        xrandr --output "${externals[0]}" --auto --above "$LAPTOP"

        local prev="${externals[0]}"
        for ((i=1; i<count; i++)); do
            xrandr --output "${externals[i]}" --auto --right-of "$prev"
            prev="${externals[i]}"
        done
        echo "Multi-monitor: ${externals[*]} above laptop"
    fi

    # Restore wallpaper
    sleep 0.5
    [[ -x ~/.fehbg ]] && ~/.fehbg

    # Refresh dwm
    pkill -USR1 -x dwm 2>/dev/null
}

# Run configuration
configure_displays
