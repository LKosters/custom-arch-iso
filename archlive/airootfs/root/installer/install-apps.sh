#!/bin/bash

TARGET_DIR="$1"
USERNAME="$2"

if [ -z "$TARGET_DIR" ]; then
    TARGET_DIR="/"
fi

echo "Installing applications..."

arch-chroot "$TARGET_DIR" bash << APPSINSTALL
cd /tmp
USER="$USERNAME"

echo "Installing Ghostty terminal..."
if command -v yay &> /dev/null; then
    yay -S --noconfirm ghostty-bin 2>/dev/null || true
else
    git clone https://aur.archlinux.org/ghostty-bin.git /tmp/ghostty-bin 2>/dev/null || true
    if [ -d "/tmp/ghostty-bin" ]; then
        chmod -R 777 /tmp/ghostty-bin
        cd /tmp/ghostty-bin
        sudo -u "\$USER" makepkg -si --noconfirm 2>/dev/null || true
    fi
fi

echo "Installing Zen Browser..."
if command -v yay &> /dev/null; then
    yay -S --noconfirm zen-browser 2>/dev/null || true
else
    git clone https://aur.archlinux.org/zen-browser.git /tmp/zen-browser 2>/dev/null || true
    if [ -d "/tmp/zen-browser" ]; then
        chmod -R 777 /tmp/zen-browser
        cd /tmp/zen-browser
        sudo -u "\$USER" makepkg -si --noconfirm 2>/dev/null || true
    fi
fi

echo "Installing Fastfetch..."
pacman -Sy --noconfirm fastfetch 2>/dev/null || \
    (if command -v yay &> /dev/null; then yay -S --noconfirm fastfetch 2>/dev/null; fi) || \
    (git clone https://aur.archlinux.org/fastfetch.git /tmp/fastfetch 2>/dev/null && \
     chmod -R 777 /tmp/fastfetch && cd /tmp/fastfetch && \
     sudo -u "\$USER" makepkg -si --noconfirm 2>/dev/null || true)

echo "Installing 1Password..."
if command -v yay &> /dev/null; then
    yay -S --noconfirm 1password-cli 2>/dev/null || true
    yay -S --noconfirm 1password 2>/dev/null || true
else
    git clone https://aur.archlinux.org/1password-cli.git /tmp/1password-cli 2>/dev/null || true
    if [ -d "/tmp/1password-cli" ]; then
        chmod -R 777 /tmp/1password-cli
        cd /tmp/1password-cli
        sudo -u "\$USER" makepkg -si --noconfirm 2>/dev/null || true
    fi
fi

echo "Installing Discord..."
pacman -Sy --noconfirm discord 2>/dev/null || \
    (if command -v yay &> /dev/null; then yay -S --noconfirm discord 2>/dev/null; fi) || \
    (wget -O /tmp/discord.tar.gz "https://discord.com/api/download?platform=linux&format=tar.gz" 2>/dev/null && \
     mkdir -p /opt && \
     tar -xzf /tmp/discord.tar.gz -C /opt/ 2>/dev/null && \
     ln -sf /opt/Discord/discord /usr/local/bin/discord 2>/dev/null || true)

pacman -Sy --noconfirm \
    firefox \
    thunar thunar-archive-plugin \
    file-roller \
    neofetch \
    htop \
    vim nano \
    git \
    python python-pip \
    nodejs npm \
    rust cargo \
    2>/dev/null || true
APPSINSTALL

echo "Applications installed"

