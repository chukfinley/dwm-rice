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
slock.color0: $bg
slock.color1: $(darken "$accent" 30)
slock.color2: $accent
slock.color3: $bg
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

# Generate additional color variants
bg_light=$(lighten "$bg" 5)
bg_lighter=$(lighten "$bg" 10)
bg_dark=$(darken "$bg" 10)
accent_dark=$(darken "$accent" 20)
accent_light=$(lighten "$accent" 20)
fg_dim=$(darken "$fg" 20)

# Update Zed IDE theme
ZED_THEMES_DIR="$HOME/.config/zed/themes"
if [[ -d "$HOME/.config/zed" ]]; then
    mkdir -p "$ZED_THEMES_DIR"
    cat > "$ZED_THEMES_DIR/wallpaper-theme.json" << EOF
{
  "\$schema": "https://zed.dev/schema/themes/v0.2.0.json",
  "name": "Wallpaper Theme",
  "author": "wal-colors.sh",
  "themes": [
    {
      "name": "Wallpaper Dark",
      "appearance": "dark",
      "style": {
        "background": "$bg",
        "editor.background": "$bg",
        "editor.foreground": "$fg",
        "editor.gutter.background": "$bg",
        "editor.active_line.background": "$bg_light",
        "editor.line_number": "$fg_dim",
        "editor.active_line_number": "$fg",
        "terminal.background": "$bg",
        "terminal.foreground": "$fg",
        "panel.background": "$bg_dark",
        "tab_bar.background": "$bg_dark",
        "tab.active_background": "$bg",
        "tab.inactive_background": "$bg_dark",
        "toolbar.background": "$bg",
        "status_bar.background": "$bg_dark",
        "title_bar.background": "$bg_dark",
        "scrollbar.track.background": "$bg",
        "scrollbar.thumb.background": "$bg_lighter",
        "element.selected": "$bg_light",
        "element.hover": "$bg_lighter",
        "element.active": "$accent",
        "text": "$fg",
        "text.muted": "$fg_dim",
        "text.accent": "$accent",
        "icon": "$fg",
        "icon.accent": "$accent",
        "border": "$border",
        "border.focused": "$accent",
        "border.selected": "$accent",
        "link_text.hover": "$accent_light",
        "players": [
          {"cursor": "$accent", "background": "$accent", "selection": "${accent}40"}
        ],
        "syntax": {
          "keyword": {"color": "$accent"},
          "function": {"color": "$accent_light"},
          "string": {"color": "$(lighten "$accent" 30)"},
          "comment": {"color": "$fg_dim"},
          "number": {"color": "$accent"},
          "type": {"color": "$accent_light"},
          "variable": {"color": "$fg"}
        }
      }
    }
  ]
}
EOF
    # Update Zed settings to use our theme
    ZED_SETTINGS="$HOME/.config/zed/settings.json"
    if [[ -f "$ZED_SETTINGS" ]]; then
        # Zed settings may have comments, use sed instead of jq
        if grep -q '"theme"' "$ZED_SETTINGS"; then
            # Replace existing theme block
            sed -i '/"theme":/,/^  }/c\  "theme": {\n    "mode": "dark",\n    "dark": "Wallpaper Dark",\n    "light": "Wallpaper Dark"\n  }' "$ZED_SETTINGS"
        else
            # Add theme before closing brace
            sed -i 's/^}$/  ,"theme": {\n    "mode": "dark",\n    "dark": "Wallpaper Dark",\n    "light": "Wallpaper Dark"\n  }\n}/' "$ZED_SETTINGS"
        fi
    fi
    echo "Zed theme updated!"
fi

# Update Cursor IDE colors
CURSOR_SETTINGS="$HOME/.config/Cursor/User/settings.json"
if [[ -f "$CURSOR_SETTINGS" ]]; then
    if command -v jq &>/dev/null; then
        tmp=$(mktemp)
        jq --arg bg "$bg" --arg fg "$fg" --arg accent "$accent" --arg border "$border" \
           --arg bg_light "$bg_light" --arg bg_dark "$bg_dark" --arg fg_dim "$fg_dim" \
           '.["workbench.colorCustomizations"] = {
              "editor.background": $bg,
              "editor.foreground": $fg,
              "editorCursor.foreground": $accent,
              "editorLineNumber.foreground": $fg_dim,
              "editorLineNumber.activeForeground": $fg,
              "editor.selectionBackground": ($accent + "40"),
              "editor.lineHighlightBackground": $bg_light,
              "sideBar.background": $bg_dark,
              "sideBar.foreground": $fg,
              "sideBarTitle.foreground": $fg,
              "activityBar.background": $bg_dark,
              "activityBar.foreground": $accent,
              "statusBar.background": $bg_dark,
              "statusBar.foreground": $fg,
              "titleBar.activeBackground": $bg_dark,
              "titleBar.activeForeground": $fg,
              "tab.activeBackground": $bg,
              "tab.inactiveBackground": $bg_dark,
              "tab.activeForeground": $fg,
              "tab.border": $border,
              "terminal.background": $bg,
              "terminal.foreground": $fg,
              "panel.background": $bg_dark,
              "panel.border": $border,
              "focusBorder": $accent,
              "list.activeSelectionBackground": $accent,
              "list.hoverBackground": $bg_light
           }' "$CURSOR_SETTINGS" > "$tmp" && mv "$tmp" "$CURSOR_SETTINGS"
        echo "Cursor IDE colors updated!"
    else
        echo "Cursor: jq not installed, skipping"
    fi
fi


# Update Discord (BetterDiscord/Vencord) theme
BETTERDISCORD_THEMES="$HOME/.config/BetterDiscord/themes"
VENCORD_THEMES="$HOME/.config/Vencord/themes"
bg_tertiary=$(darken "$bg" 15)
DISCORD_CSS="/**
 * @name Wallpaper Theme
 * @description Auto-generated theme from wallpaper
 * @author wal-colors.sh
 * @version 1.0.0
 */

:root, .theme-dark, .theme-light {
    --background-primary: $bg !important;
    --background-secondary: $bg_dark !important;
    --background-secondary-alt: $bg_dark !important;
    --background-tertiary: $bg_tertiary !important;
    --background-accent: $accent !important;
    --background-floating: $bg_dark !important;
    --background-modifier-hover: $bg_light !important;
    --background-modifier-active: $bg_lighter !important;
    --background-modifier-selected: $bg_light !important;
    --background-modifier-accent: ${accent}20 !important;
    --text-normal: $fg !important;
    --text-muted: $fg_dim !important;
    --text-link: $accent_light !important;
    --interactive-normal: $fg !important;
    --interactive-hover: $(lighten "$fg" 15) !important;
    --interactive-active: #ffffff !important;
    --interactive-muted: $fg_dim !important;
    --header-primary: $fg !important;
    --header-secondary: $fg_dim !important;
    --brand-experiment: $accent !important;
    --brand-experiment-560: $accent !important;
    --scrollbar-thin-thumb: $bg_lighter !important;
    --scrollbar-auto-thumb: $bg_lighter !important;
    --channeltextarea-background: $bg_light !important;
    --bg-overlay-1: $bg !important;
    --bg-overlay-2: $bg_dark !important;
    --bg-overlay-3: $bg_tertiary !important;
    --bg-overlay-chat: $bg !important;
    --activity-card-background: $bg_dark !important;
    --input-background: $bg_tertiary !important;
    --modal-background: $bg_dark !important;
    --modal-footer-background: $bg_tertiary !important;
}

.theme-dark, .theme-light {
    --background-primary: $bg !important;
    --background-secondary: $bg_dark !important;
    --background-tertiary: $bg_tertiary !important;
}
"
if [[ -d "$BETTERDISCORD_THEMES" ]]; then
    echo "$DISCORD_CSS" > "$BETTERDISCORD_THEMES/wallpaper.theme.css"
    echo "BetterDiscord theme updated!"
elif [[ -d "$VENCORD_THEMES" ]]; then
    echo "$DISCORD_CSS" > "$VENCORD_THEMES/wallpaper.theme.css"
    echo "Vencord theme updated!"
else
    mkdir -p "$CACHE_DIR/discord"
    echo "$DISCORD_CSS" > "$CACHE_DIR/discord/wallpaper.theme.css"
    echo "Discord theme saved to $CACHE_DIR/discord/ (install BetterDiscord/Vencord to apply)"
fi
