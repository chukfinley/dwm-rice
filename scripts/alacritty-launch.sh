#!/bin/bash
# Launch alacritty with appropriate font size based on current monitor
# External monitors get smaller text (higher res / larger physical size)

FONT_SIZE_LAPTOP="12.5"
FONT_SIZE_EXTERNAL="10.0"

# Get the monitor where the cursor is
get_cursor_monitor() {
    eval "$(xdotool getmouselocation --shell 2>/dev/null)"
    local cx="${X:-0}"
    local cy="${Y:-0}"

    while IFS= read -r line; do
        if [[ "$line" =~ ([A-Za-z0-9-]+)\ connected.*\ ([0-9]+)x([0-9]+)\+([0-9]+)\+([0-9]+) ]]; then
            local name="${BASH_REMATCH[1]}"
            local w="${BASH_REMATCH[2]}"
            local h="${BASH_REMATCH[3]}"
            local x="${BASH_REMATCH[4]}"
            local y="${BASH_REMATCH[5]}"

            if (( cx >= x && cx < x + w && cy >= y && cy < y + h )); then
                echo "$name"
                return
            fi
        fi
    done < <(xrandr --query 2>/dev/null)

    echo "unknown"
}

# Get font size based on monitor
monitor=$(get_cursor_monitor)

if [[ "$monitor" =~ ^eDP ]]; then
    font_size="$FONT_SIZE_LAPTOP"
else
    font_size="$FONT_SIZE_EXTERNAL"
fi

# Launch with per-instance font size override
exec alacritty -o "font.size=$font_size" "$@"
