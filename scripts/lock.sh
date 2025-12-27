#!/bin/bash
# Lock screen with slock and fix multi-monitor after unlock

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BT_CACHE="/tmp/.bt_headphones_cache"

# Get connected Bluetooth audio devices and disconnect them
disconnect_bt_headphones() {
    # Find connected audio devices (headphones/headsets)
    local connected=""
    while IFS= read -r line; do
        if [[ "$line" =~ Device\ ([0-9A-F:]+) ]]; then
            local mac="${BASH_REMATCH[1]}"
            # Check if it's an audio device (has audio UUID) and is connected
            local info=$(bluetoothctl info "$mac" 2>/dev/null)
            if echo "$info" | grep -q "Connected: yes" && \
               echo "$info" | grep -qE "UUID.*Audio|UUID.*A2DP|UUID.*Headset"; then
                connected="$connected $mac"
            fi
        fi
    done < <(bluetoothctl devices 2>/dev/null)

    # Save and disconnect
    if [[ -n "$connected" ]]; then
        echo "$connected" > "$BT_CACHE"
        for mac in $connected; do
            bluetoothctl disconnect "$mac" &>/dev/null
        done
    else
        rm -f "$BT_CACHE"
    fi
}

# Try to reconnect previously connected headphones (gentle, single attempt)
reconnect_bt_headphones() {
    [[ -f "$BT_CACHE" ]] || return

    local saved=$(cat "$BT_CACHE")
    rm -f "$BT_CACHE"

    # Single reconnect attempt in background, non-blocking
    for mac in $saved; do
        (sleep 2 && bluetoothctl connect "$mac" &>/dev/null) &
    done
}

# Fix external monitors (run after unlock)
fix_monitors() {
    # Wake displays first before configuring
    xset dpms force on
    sleep 1

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

    # Force DPMS on again after configuration
    xset dpms force on

    # Restore wallpaper
    [[ -x ~/.fehbg ]] && ~/.fehbg
}

# Disconnect Bluetooth headphones before locking
disconnect_bt_headphones

# Lock the screen
slock

# After unlock, try to reconnect headphones (gentle, single attempt)
reconnect_bt_headphones

# Fix displays
fix_monitors

# Signal dwm to refresh
pkill -USR1 -x dwm 2>/dev/null
