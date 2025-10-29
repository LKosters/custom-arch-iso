# Custom Arch Linux ISO Builder

A custom Arch Linux installation ISO with Hyprland, pre-configured Waybar (macOS-style), Rofi, and all your favorite apps.

## Features

- **Window Manager**: Hyprland with beautiful animations
- **Terminal**: Ghostty
- **Browser**: Zen Browser
- **Apps**: Discord, 1Password, Fastfetch
- **File Manager**: Nautilus
- **Theming**: Dark UI with Space Grotesk (body) and Instrument Serif (headings)
- **Rofi**: Custom dark theme with Alt+Space shortcut
- **Waybar**: macOS-style topbar
- **Auto-detection**: GPU drivers, partitioning assistance

## Install directly on your current Arch system (no ISO)

1. Run the installer as root:
```bash
sudo bash install-on-arch.sh
```

2. It will prompt for the target username (defaults to your current user), then install GPU drivers, packages, fonts, and write configs.

3. Log out and log back in on TTY1, or reboot. Hyprland will start automatically.

If you still want an ISO later, keep the `build-iso.sh` and `archlive/` folder, but direct install is now the primary path.

## Keyboard Shortcuts

- `Alt+Space`: Open Rofi application launcher
- `Super+Q`: Open Ghostty terminal
- `Super+E`: Open file manager
- `Super+R`: Alternative Rofi launcher
- `Super+1-0`: Switch workspaces
- `Super+Shift+1-0`: Move window to workspace
- `Super+Arrow Keys`: Move focus between windows

## Customization

All configuration files are located in `archlive/airootfs/root/configs/`:

- `hypr/` - Hyprland configuration
- `waybar/` - Waybar configuration (macOS-style)
- `rofi/` - Rofi theme and configuration
- `gtk/` - GTK theming

You can modify these before building the ISO.

## Requirements

- Arch Linux system to build the ISO
- Root access
- ~10GB free disk space for building

