#!/bin/bash

set -e

ISO_NAME="customarch"
ISO_VERSION=$(date +%Y%m%d)
WORK_DIR="iso-work"
ARCH_CHROOT="arch-chroot"

echo "Building Custom Arch Linux ISO..."

if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root"
    exit 1
fi

if [ -d "$WORK_DIR" ]; then
    rm -rf "$WORK_DIR"
fi

mkdir -p "$WORK_DIR"

echo "Installing required packages..."
pacman -Sy --noconfirm archiso 2>/dev/null || yay -S --noconfirm archiso || echo "Install archiso manually"

echo "Creating base Arch Linux installation..."
mkarchiso -v -w "$WORK_DIR" -o . archlive/

echo "ISO build complete: ${ISO_NAME}-${ISO_VERSION}.iso"

