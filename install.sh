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
echo "[1/5] Installing dependencies..."
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
    rofi

echo ""
echo "[2/5] Building and installing dwm..."
cd "$SCRIPT_DIR/dwm"
make clean
make
sudo make install

echo ""
echo "[3/5] Building and installing dmenu..."
cd "$SCRIPT_DIR/dmenu"
make clean
make
sudo make install

echo ""
echo "[4/5] Building and installing slstatus..."
cd "$SCRIPT_DIR/slstatus"
make clean
make
sudo make install

echo ""
echo "[5/5] Setting up configuration..."

# Create config directory
mkdir -p "$CONFIG_DIR/scripts"
mkdir -p "$CONFIG_DIR/sxhkd"

# Copy scripts
cp "$SCRIPT_DIR/scripts/"* "$CONFIG_DIR/scripts/"
chmod +x "$CONFIG_DIR/scripts/"*

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
echo "  Alt+Shift+N  - Set random wallpaper + apply colors"
echo "  Alt+Shift+U  - Reapply colors from current wallpaper"
echo "  Super+Shift+R - Restart dwm"
echo "  Super+D      - Open dmenu"
echo ""
