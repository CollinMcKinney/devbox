#!/bin/bash
set -euo pipefail

if [ -z "${SUDO_USER:-}" ]; then
    echo "This script must be run with sudo."
    exit 1
fi

# GPU detection and driver install.
GPU_TYPE=$(lspci | grep -E "VGA|3D" | tr '[:upper:]' '[:lower:]')

if [[ $GPU_TYPE == *"nvidia"* ]]; then
    echo "NVIDIA GPU detected but NVIDIA drivers are not configured in this script. Please install NVIDIA drivers manually after installation."
    #apt install --no-install-recommends -y \
    #   nvidia-driver \
    #   nvidia-settings \
    #   firmware-misc-nonfree \
    #   linux-headers-amd64
elif [[ $GPU_TYPE == *"amd"* ]]; then
    apt install --no-install-recommends -y \
        firmware-amd-graphics \
        libgl1-mesa-dri \
        libglx-mesa0
elif [[ $GPU_TYPE == *"intel"* ]]; then
    apt install --no-install-recommends -y \
        firmware-misc-nonfree \
        intel-media-va-driver-non-free
fi

# Login manager and theme.
apt install --no-install-recommends -y \
    sddm \
    sddm-theme-breeze \
    kde-config-sddm

# Plasma desktop.
apt install --no-install-recommends -y \
    plasma-desktop \
    plasma-workspace \
    kwin-wayland \
    xdg-desktop-portal-kde \
    libkf6config-bin \
    libqt6svg6 \
    libxcb-cursor0 \
    kscreen

if ! command -v kwriteconfig6 >/dev/null 2>&1; then
    echo "kwriteconfig6 is missing after installing GUI packages."
    echo "Expected provider package: libkf6config-bin"
    exit 1
fi

# Networking and audio stack.
apt install --no-install-recommends -y \
    network-manager \
    plasma-nm \
    bluez \
    bluedevil \
    plasma-pa \
    pipewire-audio \
    libspa-0.2-bluetooth

echo "GUI stage complete"
