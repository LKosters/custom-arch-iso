#!/bin/bash

TARGET_DIR="$1"
USERNAME="$2"

echo "Setting up autostart for Hyprland..."

arch-chroot "$TARGET_DIR" bash << AUTOSTART
cat > /home/$USERNAME/.zprofile << 'ZPROFILE'
if [ -z "\$DISPLAY" ] && [ "\$(tty)" = /dev/tty1 ]; then
    exec Hyprland
fi
ZPROFILE

chown $USERNAME:$USERNAME /home/$USERNAME/.zprofile

echo "[Desktop Entry]
Name=Hyprland
Comment=Hyprland Window Manager
Exec=Hyprland
Type=Application
" > /home/$USERNAME/.config/autostart/hyprland.desktop 2>/dev/null || true

mkdir -p /home/$USERNAME/.config/autostart
chown -R $USERNAME:$USERNAME /home/$USERNAME/.config
AUTOSTART

echo "Autostart configured"

