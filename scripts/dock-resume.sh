#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export DISPLAY=:0
export XAUTHORITY=/home/user/.Xauthority

case $1 in
post)
    sleep 2
    # Get external monitors
    EXTERNALS=$(xrandr --query | grep " connected" | grep -v "eDP" | cut -d' ' -f1)

    # Turn them off explicitly with xrandr
    for mon in $EXTERNALS; do
        xrandr --output "$mon" --off
    done
    sleep 2

    # Turn them back on
    xset dpms force on
    sleep 1
    "$SCRIPT_DIR/monitor-hotplug.sh"
    ;;
esac
