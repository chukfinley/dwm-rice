#!/bin/bash
# Lock screen with slock and handle multi-monitor setup
# Turns off external displays before lock, restores after unlock

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get list of connected external monitors (not the laptop screen)
get_external_monitors() {
    xrandr --query | grep " connected" | grep -v "eDP" | cut -d' ' -f1
}

# Save current monitor state
save_monitor_state() {
    xrandr --query > /tmp/monitor-state-before-lock
}

# Turn off external monitors
disable_external_monitors() {
    for mon in $(get_external_monitors); do
        xrandr --output "$mon" --off
    done
}

# Restore external monitors
enable_external_monitors() {
    # Use autorandr if available, otherwise use xrandr auto
    if command -v autorandr &>/dev/null; then
        autorandr --change 2>/dev/null
    else
        # Simple restore - turn monitors back on with auto settings
        for mon in $(get_external_monitors); do
            xrandr --output "$mon" --auto
        done
        # Give displays time to initialize
        sleep 1
        # Arrange them (adjust as needed for your setup)
        # Default: external monitors above laptop
        xrandr --output DP-3-1 --auto --above eDP-1 2>/dev/null
        xrandr --output DP-3-2 --auto --right-of DP-3-1 2>/dev/null
    fi

    # Reset DPMS to ensure displays are on
    xset dpms force on

    # Restore wallpaper
    [[ -x ~/.fehbg ]] && ~/.fehbg
}

# Main
save_monitor_state

# Turn off external displays before lock (saves power, security)
disable_external_monitors

# Lock the screen
slock

# After unlock, restore displays
enable_external_monitors

# Signal dwm to refresh (in case of any display changes)
pkill -USR1 -x dwm 2>/dev/null
