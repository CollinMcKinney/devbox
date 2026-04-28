#!/bin/bash
set -euo pipefail

if [ -z "${SUDO_USER:-}" ]; then
    echo "This script must be run with sudo: sudo bash install.sh"
    exit 1
fi

# ============================================================
# GPU detection – build vendor flags
# ============================================================
echo "=== Detecting GPUs ==="
GPU_INFO=$(lspci | grep -E "VGA|3D" | tr '[:upper:]' '[:lower:]')

HAS_NVIDIA=false
HAS_AMD=false
HAS_INTEL=false

if echo "$GPU_INFO" | grep -q "nvidia"; then
    HAS_NVIDIA=true
fi
if echo "$GPU_INFO" | grep -q "amd"; then
    HAS_AMD=true
fi
if echo "$GPU_INFO" | grep -q "intel"; then
    HAS_INTEL=true
fi

echo "NVIDIA: $HAS_NVIDIA, AMD: $HAS_AMD, INTEL: $HAS_INTEL"
echo ""

# ============================================================
# NVIDIA driver installation
# ============================================================
if $HAS_NVIDIA; then
    echo "=== Installing NVIDIA driver ==="
    apt install --no-install-recommends -y \
        nvidia-detect \
        linux-headers-"$(uname -r)"

    # Let the tool pick the exact driver for this GPU
    RECOMMENDED_DRIVER=$(nvidia-detect 2>/dev/null | grep -oP 'nvidia-[\w-]+' | head -1)
    if [ -z "$RECOMMENDED_DRIVER" ]; then
        echo "ERROR: nvidia-detect could not determine the correct driver package."
        echo "Please check your sources.list (contrib & non-free)."
        exit 1
    fi

    echo "Installing recommended driver: $RECOMMENDED_DRIVER"
    apt install --no-install-recommends -y \
        "$RECOMMENDED_DRIVER" \
        nvidia-settings \
        firmware-misc-nonfree

    # Hybrid system check – install nvidia-prime only if there is any non-NVIDIA GPU
    NON_NVIDIA_COUNT=$(lspci | grep -E "VGA|3D" | grep -civ "NVIDIA")
    if [ "$NON_NVIDIA_COUNT" -gt 0 ]; then
        echo "Hybrid system (NVIDIA + other GPU). Installing nvidia-prime."
        apt install -y nvidia-prime
    else
        echo "Single NVIDIA GPU(s). nvidia-prime not required."
    fi
    echo ""
fi

# ============================================================
# AMD GPU installation
# ============================================================
if $HAS_AMD; then
    echo "=== Installing AMD drivers ==="
    apt install --no-install-recommends -y \
        firmware-amd-graphics \
        libgl1-mesa-dri \
        libglx-mesa0
    echo ""
fi

# ============================================================
# Intel GPU installation
# ============================================================
if $HAS_INTEL; then
    echo "=== Installing Intel GPU drivers ==="
    apt install --no-install-recommends -y \
        firmware-misc-nonfree \
        intel-media-va-driver
    echo ""
fi

echo "=== GPU installation complete ==="