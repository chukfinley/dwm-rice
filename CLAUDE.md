# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands

```bash
# Full installation (dependencies + all components)
./install.sh

# Build individual components (after changing config.h)
cd dwm && sudo make clean install
cd dmenu && sudo make clean install
cd slstatus && sudo make clean install
cd slock && sudo make clean install

# Reload dwm without restarting X session (after recompile)
pkill -USR1 dwm

# Reload sxhkd keybindings
pkill -USR1 -x sxhkd

# Copy scripts to live config after editing
cp scripts/*.sh ~/.config/dwm/scripts/
```

## Architecture

This is a suckless-based Linux desktop environment with live wallpaper-based theming.

### Core Components
- **dwm/** - Window manager (C, config.h for customization)
- **dmenu/** - Application launcher
- **slstatus/** - Status bar (shows media, CPU, RAM, disk, volume, time)
- **slock/** - Screen locker with Xresources color support
- **sxhkd/sxhkdrc** - Keybindings (independent of dwm)

### Key Scripts (scripts/)
- **wal-colors.sh** - Extracts colors from wallpaper, applies to dwm/dmenu/slock/alacritty/GTK/Zed/Discord
- **setwall.sh** - Sets wallpaper and triggers wal-colors.sh
- **lock.sh** - Locks screen, handles Bluetooth headphone disconnect/reconnect, fixes monitors on unlock
- **monitor-hotplug.sh** - Auto-configures monitors on dock/undock (triggered by udev)
- **autolock.sh** - Idle detection with video playback inhibition
- **alacritty-launch.sh** - DPI-aware terminal (different font sizes per monitor)

### Color Theming Flow
1. `setwall.sh` or `Alt+Shift+N` selects wallpaper
2. `wal-colors.sh` extracts palette with ImageMagick
3. Colors written to `~/.cache/dwm-colors/xcolors` (Xresources format)
4. `xrdb -merge` loads colors, `pkill -USR1 dwm` triggers reload
5. Theme also applied to alacritty, GTK3, Zed, Discord, folder icons

### Monitor Handling
- Udev rules at `/etc/udev/rules.d/95-monitor-hotplug.rules` trigger `monitor-hotplug.sh`
- Designed for laptop + external monitors (dock scenario)
- External monitors placed above laptop display (eDP-1)
- Special handling for dual ultrawide MST dock (DP-3-1 + DP-3-2)

### Signal Communication
- `pkill -USR1 dwm` - Reload colors from Xresources
- `pkill -USR1 -x sxhkd` - Reload keybindings

### Runtime Locations
- Config: `~/.config/dwm/` (scripts, sxhkd config, picom.conf)
- Color cache: `~/.cache/dwm-colors/`
- Wallpapers: `~/Pictures/wal/`
- Desktop entry: `/usr/share/xsessions/dwm.desktop`

## Key Keybindings (sxhkd)
- `Super+W` - Lock screen
- `Super+Return` - Terminal (alacritty)
- `Super+Shift+D` - dmenu
- `Alt+Shift+N` - Random wallpaper + colors
- `Alt+Shift+U` - Reapply colors from current wallpaper
