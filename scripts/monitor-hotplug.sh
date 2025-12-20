#!/bin/bash
# Auto-detect dock/monitor connection and configure displays
# Laptop screen stays on, external monitors go above it

LAPTOP="eDP-1"

# Get connected external monitors
get_external_monitors() {
    xrandr --query | grep " connected" | grep -v "$LAPTOP" | cut -d' ' -f1
}

# Configure displays based on what's connected
configure_displays() {
    local externals=($(get_external_monitors))
    local count=${#externals[@]}

    if (( count == 0 )); then
        # No external monitors - just laptop
        xrandr --output "$LAPTOP" --auto --primary
        echo "Laptop only mode"
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
