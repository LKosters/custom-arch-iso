#!/bin/bash

set -e

INSTALLER_DIR="/root/installer"
CONFIGS_DIR="/root/configs"

chmod +x "${INSTALLER_DIR}/install.sh"
chmod +x "${INSTALLER_DIR}/detect-gpu.sh"
chmod +x "${INSTALLER_DIR}/setup-hyprland.sh"
chmod +x "${INSTALLER_DIR}/setup-fonts.sh"
chmod +x "${INSTALLER_DIR}/install-apps.sh"
chmod +x "${INSTALLER_DIR}/setup-autostart.sh"

echo "Custom Arch installer ready"

