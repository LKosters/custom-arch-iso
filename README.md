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

## Building the ISO

1. Install required packages:
```bash
sudo pacman -S archiso
```

2. Make the build script executable:
```bash
chmod +x build-iso.sh
```

3. Run the build script as root:
```bash
sudo ./build-iso.sh
```

4. The ISO will be created in the current directory as `customarch-YYYYMMDD.iso`

## Using the ISO

1. Flash the ISO to a USB drive:
```bash
sudo dd if=customarch-*.iso of=/dev/sdX bs=4M status=progress
```

2. Boot from the USB drive

3. The system will auto-login as root. Run the installer:
```bash
/root/installer/install.sh
```

4. Follow the prompts:
   - Select target partition
   - Enter username
   - Enter passwords
   - Choose whether to format partition

5. Reboot and login with your username. Hyprland will start automatically.

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

