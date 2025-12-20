#!/bin/bash
# Extract colors from wallpaper and update dwm LIVE
# Usage: wal-colors.sh [wallpaper_path]

CACHE_DIR="$HOME/.cache/dwm-colors"
mkdir -p "$CACHE_DIR"

# Get wallpaper path
get_wallpaper() {
    if [[ -n "$1" ]]; then
        echo "$1"
    elif [[ -f "$HOME/.fehbg" ]]; then
        grep -oP "(?<=['\"])[^'\"]+\.(jpg|jpeg|png|gif|bmp|webp)(?=['\"])" "$HOME/.fehbg" | head -1
    fi
}

# Extract colors using ImageMagick
extract_colors() {
    convert "$1" -resize 100x100! -colors 8 -unique-colors txt:- | \
        grep -oP '#[0-9A-Fa-f]{6}' | head -8
}

# Get luminance
get_lum() {
    local hex="${1#\#}"
    local r=$((16#${hex:0:2})) g=$((16#${hex:2:2})) b=$((16#${hex:4:2}))
    echo $(( (r * 299 + g * 587 + b * 114) / 1000 ))
}

# Darken color
darken() {
    local hex="${1#\#}" p="$2"
    local r=$((16#${hex:0:2} * (100-p) / 100))
    local g=$((16#${hex:2:2} * (100-p) / 100))
    local b=$((16#${hex:4:2} * (100-p) / 100))
    printf "#%02x%02x%02x" "$r" "$g" "$b"
}

# Lighten color
lighten() {
    local hex="${1#\#}" p="$2"
    local r=$((16#${hex:0:2})) g=$((16#${hex:2:2})) b=$((16#${hex:4:2}))
    r=$((r + (255-r) * p / 100))
    g=$((g + (255-g) * p / 100))
    b=$((b + (255-b) * p / 100))
    printf "#%02x%02x%02x" "$r" "$g" "$b"
}

# Main
wallpaper=$(get_wallpaper "$1")
[[ -z "$wallpaper" ]] && { echo "No wallpaper found"; exit 1; }

echo "Extracting colors from: $wallpaper"
mapfile -t colors < <(extract_colors "$wallpaper")
(( ${#colors[@]} < 2 )) && { echo "Not enough colors"; exit 1; }

# Find darkest and accent
darkest="${colors[0]}" darkest_lum=256 accent="" accent_sat=0
for c in "${colors[@]}"; do
    lum=$(get_lum "$c")
    (( lum < darkest_lum )) && { darkest="$c"; darkest_lum=$lum; }
    if (( lum > 60 && lum < 200 )); then
        hex="${c#\#}"
        r=$((16#${hex:0:2})) g=$((16#${hex:2:2})) b=$((16#${hex:4:2}))
        max=$(( r>g ? (r>b?r:b) : (g>b?g:b) ))
        min=$(( r<g ? (r<b?r:b) : (g<b?g:b) ))
        sat=$((max-min))
        (( sat > accent_sat )) && { accent="$c"; accent_sat=$sat; }
    fi
done
[[ -z "$accent" ]] && accent="${colors[1]:-${colors[0]}}"

# Generate scheme
(( darkest_lum > 50 )) && darkest=$(darken "$darkest" 70)
bg=$(darken "$darkest" 20)
(( $(get_lum "$bg") > 40 )) && bg="#222222"
border=$(lighten "$bg" 15)
fg=$(lighten "$bg" 60)

echo "Scheme: bg=$bg accent=$accent"

# Write to xrdb (dwm + dmenu)
cat > "$CACHE_DIR/xcolors" << EOF
dwm.normfg: $fg
dwm.normbg: $bg
dwm.normborder: $border
dwm.selfg: #eeeeee
dwm.selbg: $accent
dwm.selborder: $accent
dmenu.normfg: $fg
dmenu.normbg: $bg
dmenu.selfg: #eeeeee
dmenu.selbg: $accent
EOF

# Apply to X and signal dwm
xrdb -merge "$CACHE_DIR/xcolors"
pkill -USR1 -x dwm 2>/dev/null && echo "dwm colors applied!" || echo "Colors saved (dwm not running)"

# Update alacritty colors
ALACRITTY_CONF="$HOME/.config/alacritty/alacritty.toml"
if [[ -f "$ALACRITTY_CONF" ]]; then
    # Create temp file with updated colors
    cat > "$CACHE_DIR/alacritty-colors.toml" << EOF
[colors.primary]
background = '$bg'
foreground = '$fg'
EOF

    # Update or append colors section
    if grep -q '\[colors\.primary\]' "$ALACRITTY_CONF"; then
        # Update existing colors - replace the primary section
        sed -i "/\[colors\.primary\]/,/^$\|^\[/{
            /background/s/=.*/= '$bg'/
            /foreground/s/=.*/= '$fg'/
        }" "$ALACRITTY_CONF"
    else
        # Append colors section
        echo "" >> "$ALACRITTY_CONF"
        cat "$CACHE_DIR/alacritty-colors.toml" >> "$ALACRITTY_CONF"
    fi
    echo "Alacritty colors updated!"
fi
