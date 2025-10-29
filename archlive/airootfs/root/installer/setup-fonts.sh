#!/bin/bash

TARGET_DIR="$1"

if [ -z "$TARGET_DIR" ]; then
    TARGET_DIR="/"
fi

echo "Installing fonts..."

arch-chroot "$TARGET_DIR" bash << EOF
cd /tmp

echo "Installing Space Grotesk font..."
curl -L https://github.com/floriankarsten/space-grotesk/releases/download/2.0.0/SpaceGrotesk-2.0.0.zip -o /tmp/space-grotesk.zip 2>/dev/null || \
    git clone --depth 1 https://github.com/floriankarsten/space-grotesk.git /tmp/space-grotesk 2>/dev/null || true

if [ -f "/tmp/space-grotesk.zip" ]; then
    unzip -q /tmp/space-grotesk.zip -d /tmp/space-grotesk 2>/dev/null || true
fi

if [ -d "/tmp/space-grotesk" ]; then
    mkdir -p /usr/share/fonts/TTF/space-grotesk
    find /tmp/space-grotesk -name "*.ttf" -exec cp {} /usr/share/fonts/TTF/space-grotesk/ \; 2>/dev/null || true
    find /tmp/space-grotesk -name "*.otf" -exec cp {} /usr/share/fonts/TTF/space-grotesk/ \; 2>/dev/null || true
    fc-cache -fv
fi

echo "Installing Instrument Serif font..."
curl -L https://github.com/Instrument/instrument-serif/releases/latest/download/fonts.zip -o /tmp/instrument-serif.zip 2>/dev/null || \
    git clone --depth 1 https://github.com/Instrument/instrument-serif.git /tmp/instrument-serif 2>/dev/null || true

if [ -f "/tmp/instrument-serif.zip" ]; then
    unzip -q /tmp/instrument-serif.zip -d /tmp/instrument-serif 2>/dev/null || true
fi

if [ -d "/tmp/instrument-serif" ]; then
    mkdir -p /usr/share/fonts/TTF/instrument-serif
    find /tmp/instrument-serif -name "*.ttf" -exec cp {} /usr/share/fonts/TTF/instrument-serif/ \; 2>/dev/null || true
    find /tmp/instrument-serif -name "*.otf" -exec cp {} /usr/share/fonts/TTF/instrument-serif/ \; 2>/dev/null || true
    find /tmp/instrument-serif -path "*/fonts/*" -name "*.ttf" -exec cp {} /usr/share/fonts/TTF/instrument-serif/ \; 2>/dev/null || true
    find /tmp/instrument-serif -path "*/fonts/*" -name "*.otf" -exec cp {} /usr/share/fonts/TTF/instrument-serif/ \; 2>/dev/null || true
    fc-cache -fv
fi

pacman -Sy --noconfirm ttf-dejavu ttf-liberation noto-fonts ttf-font-awesome unzip 2>/dev/null || true
EOF

echo "Fonts installed"

