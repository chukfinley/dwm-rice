# dwm-rice

A complete dwm (dynamic window manager) setup with live wallpaper-based color theming for Linux.

## Features

- **Live Color Theming** - Extracts colors from your wallpaper and applies them to:
  - dwm (window manager)
  - dmenu
  - slock (screen locker)
  - Alacritty terminal
  - Zed IDE
  - Cursor IDE
  - Discord (BetterDiscord/Vencord)

- **Smart Multi-Monitor Support**
  - Auto-detect dock/undock
  - External monitors positioned above laptop
  - Laptop screen stays on when docked
  - Per-monitor DPI scaling for Alacritty

- **Screen Locking**
  - Themed slock with Xresources support
  - Auto-lock after 3 minutes idle
  - Video playback detection (won't lock during videos)

## Components

| Component | Description |
|-----------|-------------|
| `dwm/` | Dynamic window manager with Xresources color support |
| `dmenu/` | Application launcher with live theming |
| `slstatus/` | Status bar |
| `slock/` | Screen locker with Xresources colors |
| `scripts/` | Wallpaper, color extraction, monitor handling |
| `sxhkd/` | Hotkey daemon configuration |

## Installation

```bash
git clone https://github.com/chukfinley/dwm-rice.git
cd dwm-rice
./install.sh
```

Add wallpapers to `~/Pictures/wal/` and log out. Select "dwm" from your display manager.

## Keybindings

| Key | Action |
|-----|--------|
| `Alt+Shift+N` | Random wallpaper + apply colors |
| `Alt+Shift+U` | Reapply colors from current wallpaper |
| `Super+Return` | Open Alacritty (DPI-aware) |
| `Super+Shift+D` | Open dmenu |
| `Super+W` | Lock screen |
| `Super+Shift+R` | Restart dwm |

## Included Configs

- `.zshrc` - ZSH config with syntax highlighting, autosuggestions, zoxide, bookmarks
- `.tmux.conf` - Tmux config with vi keys, C-a prefix

## Scripts

- `wal-colors.sh` - Extract colors from wallpaper and apply everywhere
- `setwall.sh` - Set random wallpaper and apply colors
- `lock.sh` - Lock screen with monitor fix on unlock
- `dock-layout.sh` / `undock-layout.sh` - Monitor layout switching
- `alacritty-launch.sh` - Launch terminal with per-monitor font size
- `monitor-hotplug.sh` - Auto-configure displays on plug/unplug

## Dependencies

- Xorg, dwm, dmenu, slock, slstatus
- feh, picom, sxhkd, imagemagick
- alacritty, rofi, xdotool
- zsh, tmux (optional)

## Post-Install: Zen Browser Memory Management

Zen/Firefox can leak RAM over time. Configure auto-cleanup in `about:config`:

| Setting | Value | Description |
|---------|-------|-------------|
| `browser.tabs.unloadOnLowMemory` | `true` | Auto-unload tabs when RAM low |
| `browser.low_commit_space_threshold_mb` | `4000` | Trigger at <4GB free |
| `browser.tabs.min_inactive_duration_before_unload` | `300` | After 5 min inactive |
| `browser.sessionhistory.max_entries` | `10` | Less history per tab |

Manual cleanup: `about:memory` → "Minimize memory usage"

## License

MIT
