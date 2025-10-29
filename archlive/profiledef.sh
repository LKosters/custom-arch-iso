#!/bin/bash

archinstall iso_mode="autodetect" \
  iso_label="CUSTOMARCH" \
  iso_publisher="Custom Arch Linux <custom@archlinux.org>" \
  iso_application="Custom Arch Linux Live/Rescue CD" \
  iso_version=$(date +%Y.%m.%d) \
  install_dir="arch"

