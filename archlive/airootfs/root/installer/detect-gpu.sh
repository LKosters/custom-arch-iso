#!/bin/bash

GPU_VENDOR=$(lspci | grep -i vga | grep -oE 'NVIDIA|AMD|Intel')

case "$GPU_VENDOR" in
    NVIDIA)
        echo "nvidia nvidia-utils nvidia-settings"
        ;;
    AMD)
        echo "mesa vulkan-radeon lib32-vulkan-radeon xf86-video-amdgpu"
        ;;
    Intel)
        echo "mesa vulkan-intel lib32-vulkan-intel intel-media-driver"
        ;;
    *)
        echo "mesa"
        ;;
esac

