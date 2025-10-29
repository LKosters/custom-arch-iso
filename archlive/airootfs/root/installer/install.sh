#!/bin/bash

set -e

INSTALLER_DIR="/root/installer"
CONFIGS_DIR="/root/configs"
TARGET_DIR="/mnt"

if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root"
    exit 1
fi

echo "=== Custom Arch Linux Installer ==="

echo "Scanning for partitions..."
lsblk

echo ""
read -p "Enter target partition (e.g., /dev/sda1): " TARGET_PART
read -p "Enter username: " USERNAME
read -p "Enter user password: " -s USER_PASSWORD
echo ""
read -p "Enter root password: " -s ROOT_PASSWORD
echo ""

read -p "Format partition? (y/n): " FORMAT_PART
if [ "$FORMAT_PART" = "y" ]; then
    echo "Formatting partition..."
    mkfs.ext4 -F "$TARGET_PART"
fi

echo "Mounting partition..."
mount "$TARGET_PART" "$TARGET_DIR"

echo "Installing base system..."
pacstrap "$TARGET_DIR" base base-devel linux linux-firmware \
    networkmanager sudo git wget curl openssh unzip \
    pipewire pipewire-pulse pipewire-jack pipewire-alsa \
    wireplumber pavucontrol \
    hyprland waybar rofi \
    gtk3 gtk4 qt5ct qt6ct \
    nautilus \
    noto-fonts ttf-font-awesome \
    python python-pip \
    polkit-gnome xdg-desktop-portal-hyprland \
    xdg-desktop-portal-gtk xdg-utils

GENFSTAB_CMD="genfstab -U $TARGET_DIR >> $TARGET_DIR/etc/fstab"
eval "$GENFSTAB_CMD"

echo "Detecting GPU..."
GPU_DRIVERS=$("${INSTALLER_DIR}/detect-gpu.sh")
arch-chroot "$TARGET_DIR" pacman -Sy --noconfirm $GPU_DRIVERS

echo "Setting root password..."
arch-chroot "$TARGET_DIR" bash -c "echo 'root:${ROOT_PASSWORD}' | chpasswd"

echo "Creating user..."
arch-chroot "$TARGET_DIR" useradd -m -G wheel,audio,video,optical,storage "$USERNAME"
arch-chroot "$TARGET_DIR" bash -c "echo '${USERNAME}:${USER_PASSWORD}' | chpasswd"
arch-chroot "$TARGET_DIR" bash -c "echo '%wheel ALL=(ALL:ALL) NOPASSWD: ALL' >> /etc/sudoers"

echo "Setting timezone..."
arch-chroot "$TARGET_DIR" ln -sf /usr/share/zoneinfo/UTC /etc/localtime
arch-chroot "$TARGET_DIR" hwclock --systohc

echo "Setting locale..."
echo "en_US.UTF-8 UTF-8" >> "$TARGET_DIR/etc/locale.gen"
arch-chroot "$TARGET_DIR" locale-gen
echo "LANG=en_US.UTF-8" > "$TARGET_DIR/etc/locale.conf"

echo "Setting hostname..."
echo "customarch" > "$TARGET_DIR/etc/hostname"

echo "Enabling services..."
arch-chroot "$TARGET_DIR" systemctl enable NetworkManager
arch-chroot "$TARGET_DIR" systemctl enable sshd

echo "Installing fonts..."
"${INSTALLER_DIR}/setup-fonts.sh" "$TARGET_DIR"

echo "Installing yay AUR helper..."
arch-chroot "$TARGET_DIR" bash << YAYINSTALL
cd /tmp
USER="$USERNAME"
sudo -u "\$USER" git clone https://aur.archlinux.org/yay.git /tmp/yay 2>/dev/null || true
if [ -d "/tmp/yay" ]; then
    chmod -R 777 /tmp/yay
    cd /tmp/yay
    sudo -u "\$USER" makepkg -si --noconfirm 2>/dev/null || true
fi
YAYINSTALL

echo "Installing applications..."
"${INSTALLER_DIR}/install-apps.sh" "$TARGET_DIR" "$USERNAME"

echo "Setting up Hyprland..."
"${INSTALLER_DIR}/setup-hyprland.sh" "$TARGET_DIR" "$USERNAME" "$CONFIGS_DIR"

echo "Setting up autostart..."
"${INSTALLER_DIR}/setup-autostart.sh" "$TARGET_DIR" "$USERNAME"

echo "Setting up environment variables..."
arch-chroot "$TARGET_DIR" bash << 'ENVSETUP'
echo "export QT_QPA_PLATFORMTHEME=gtk2" >> /etc/environment
echo "export _JAVA_AWT_WM_NONREPARENTING=1" >> /etc/environment
ENVSETUP

echo "Installation complete!"
echo "Reboot and login as $USERNAME"
echo "Hyprland will start automatically on login"

