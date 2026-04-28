#!/bin/bash
set -euo pipefail

if [ -z "${SUDO_USER:-}" ]; then
    echo "This script must be run with sudo: sudo bash install.sh"
    exit 1
fi

# ============================================================
# GPU detection – set vendor flags
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

    RECOMMENDED_DRIVER=$(nvidia-detect 2>/dev/null | grep -oP 'nvidia-[\w-]+' | head -1)
    if [ -z "$RECOMMENDED_DRIVER" ]; then
        echo "ERROR: nvidia-detect could not determine the correct driver package."
        exit 1
    fi

    echo "Installing recommended driver: $RECOMMENDED_DRIVER"
    apt install --no-install-recommends -y \
        "$RECOMMENDED_DRIVER" \
        nvidia-settings \
        firmware-misc-nonfree

    # Blacklist nouveau
    cat > /etc/modprobe.d/blacklist-nouveau.conf <<EOF
blacklist nouveau
options nouveau modeset=0
EOF
    update-initramfs -u
    echo "nouveau blacklisted. NVIDIA driver will activate after reboot."

    # Hybrid system? Create prime-run wrapper (no nvidia-prime needed)
    NON_NVIDIA_COUNT=$(lspci | grep -E "VGA|3D" | grep -civ "NVIDIA" || true)
    if [ "$NON_NVIDIA_COUNT" -gt 0 ]; then
        echo "Hybrid system (NVIDIA + other GPU). Setting up PRIME render offload."
        cat > /usr/local/bin/prime-run <<'PRIMEEOF'
#!/bin/bash
__NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia "$@"
PRIMEEOF
        chmod +x /usr/local/bin/prime-run
    else
        echo "Single NVIDIA GPU(s). PRIME offloading not required."
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