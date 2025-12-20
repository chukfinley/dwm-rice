#!/bin/bash
# Install script for dwm-rice on Linux Mint / Ubuntu / Debian
# This installs dwm, dmenu, slstatus with live color theming

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config/dwm"

echo "========================================"
echo "  dwm-rice installer for Linux Mint"
echo "========================================"
echo ""

# Check for root
if [[ $EUID -eq 0 ]]; then
    echo "Do not run this script as root. Run as your normal user."
    exit 1
fi

# Install dependencies
echo "[1/6] Installing dependencies..."
sudo apt update
sudo apt install -y \
    build-essential \
    libx11-dev \
    libxft-dev \
    libxinerama-dev \
    libfreetype6-dev \
    libfontconfig1-dev \
    xorg \
    feh \
    picom \
    sxhkd \
    imagemagick \
    numlockx \
    xdotool \
    alacritty \
    rofi \
    slock \
    xautolock \
    jq \
    pulseaudio-utils

echo ""
echo "[2/6] Building and installing dwm..."
cd "$SCRIPT_DIR/dwm"
make clean
make
sudo make install

echo ""
echo "[3/6] Building and installing dmenu..."
cd "$SCRIPT_DIR/dmenu"
make clean
make
sudo make install

echo ""
echo "[4/6] Building and installing slstatus..."
cd "$SCRIPT_DIR/slstatus"
make clean
make
sudo make install

echo ""
echo "[5/6] Building and installing slock (with theming)..."
cd "$SCRIPT_DIR/slock"
make clean
make
sudo make install

echo ""
echo "[6/6] Setting up configuration..."

# Create config directory
mkdir -p "$CONFIG_DIR/scripts"
mkdir -p "$CONFIG_DIR/sxhkd"

# Copy scripts
cp "$SCRIPT_DIR/scripts/"*.sh "$CONFIG_DIR/scripts/"
chmod +x "$CONFIG_DIR/scripts/"*

# Install monitor hotplug udev rule
echo "Setting up monitor hotplug detection..."
sudo cp "$SCRIPT_DIR/scripts/monitor-hotplug-trigger" /usr/local/bin/
sudo chmod +x /usr/local/bin/monitor-hotplug-trigger
sudo cp "$SCRIPT_DIR/scripts/95-monitor-hotplug.rules" /etc/udev/rules.d/
sudo udevadm control --reload-rules

# Copy autostart and picom
cp "$SCRIPT_DIR/autostart.sh" "$CONFIG_DIR/"
cp "$SCRIPT_DIR/picom.conf" "$CONFIG_DIR/"
chmod +x "$CONFIG_DIR/autostart.sh"

# Copy sxhkd config
cp "$SCRIPT_DIR/sxhkd/sxhkdrc" "$CONFIG_DIR/sxhkd/"

# Update autostart.sh to use correct user path
sed -i "s|/home/user|$HOME|g" "$CONFIG_DIR/autostart.sh"

# Update sxhkdrc to use correct user path
sed -i "s|/home/user|$HOME|g" "$CONFIG_DIR/sxhkd/sxhkdrc"

# Create wallpaper directory if it doesn't exist
mkdir -p "$HOME/Pictures/wal"

# Setup Zed IDE config if Zed is installed
if [[ -d "$HOME/.config/zed" ]] || command -v zed &>/dev/null; then
    echo "Setting up Zed IDE configuration..."
    mkdir -p "$HOME/.config/zed/themes"

    # Create Zed settings with larger fonts and theme support
    if [[ ! -f "$HOME/.config/zed/settings.json" ]]; then
        cat > "$HOME/.config/zed/settings.json" << 'ZEDEOF'
{
  "telemetry": {
    "diagnostics": false,
    "metrics": false
  },
  "ui_font_size": 18,
  "buffer_font_size": 16,
  "theme": {
    "mode": "dark",
    "dark": "Wallpaper Dark",
    "light": "Wallpaper Dark"
  }
}
ZEDEOF
    else
        # Update existing settings with jq if available
        if command -v jq &>/dev/null; then
            tmp=$(mktemp)
            jq '.ui_font_size = 18 | .buffer_font_size = 16' "$HOME/.config/zed/settings.json" > "$tmp" && mv "$tmp" "$HOME/.config/zed/settings.json"
        fi
    fi
fi

# Create desktop entry
echo "Creating desktop entry..."
sudo tee /usr/share/xsessions/dwm.desktop > /dev/null << EOF
[Desktop Entry]
Name=dwm
Comment=Dynamic window manager with live theming
Exec=$CONFIG_DIR/autostart.sh
Type=Application
EOF

echo ""
echo "========================================"
echo "  Installation complete!"
echo "========================================"
echo ""
echo "Next steps:"
echo "1. Add wallpapers to ~/Pictures/wal/"
echo "2. Log out and select 'dwm' from your display manager"
echo ""
echo "Keybindings:"
echo "  Alt+Shift+N   - Set random wallpaper + apply colors"
echo "  Alt+Shift+U   - Reapply colors from current wallpaper"
echo "  Super+W       - Lock screen"
echo "  Super+Shift+R - Restart dwm"
echo "  Super+Shift+D - Open dmenu"
echo ""
echo "Auto-lock:"
echo "  Screen locks after 3 minutes of inactivity"
echo "  Will NOT lock if video/audio is playing"
echo ""
