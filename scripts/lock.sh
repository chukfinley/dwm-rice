#!/bin/bash
# Lock screen with slock and fix multi-monitor after unlock

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Fix external monitors (run after unlock)
fix_monitors() {
    # Use autorandr if available, otherwise use xrandr auto
    if command -v autorandr &>/dev/null; then
        autorandr --change 2>/dev/null
    else
        # Get external monitors and set them up
        for mon in $(xrandr --query | grep " connected" | grep -v "eDP" | cut -d' ' -f1); do
            xrandr --output "$mon" --auto
        done
        sleep 0.5
        # Arrange them (adjust as needed for your setup)
        xrandr --output DP-3-1 --auto --above eDP-1 2>/dev/null
        xrandr --output DP-3-2 --auto --right-of DP-3-1 2>/dev/null
    fi

    # Reset DPMS to ensure displays are on
    xset dpms force on

    # Restore wallpaper
    [[ -x ~/.fehbg ]] && ~/.fehbg
}

# Lock the screen
slock

# After unlock, fix displays
fix_monitors

# Signal dwm to refresh
pkill -USR1 -x dwm 2>/dev/null
