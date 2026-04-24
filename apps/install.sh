#!/bin/bash
set -euo pipefail

if [ -z "${SUDO_USER:-}" ]; then
    echo "This script must be run with sudo."
    exit 1
fi

# Desktop applications and media codecs.
apt install --no-install-recommends -y \
    firefox-esr \
    dolphin \
    konsole-kpart \
    ffmpeg \
    libavcodec-extra

# VS Codium.
echo "Installing VS Codium (native .deb)..."
CODIUM_LATEST=$(curl -s https://api.github.com/repos/VSCodium/vscodium/releases/latest | grep "browser_download_url.*amd64.deb" | grep -v "riscv64" | head -1 | cut -d '"' -f 4)

if [ -n "$CODIUM_LATEST" ]; then
    echo "Downloading Codium from: $CODIUM_LATEST"
    curl -fL "$CODIUM_LATEST" -o /tmp/codium.deb
    apt install -y /tmp/codium.deb
    rm -f /tmp/codium.deb
else
    echo "Failed to get latest Codium version, trying fallback..."
    curl -fL "https://github.com/VSCodium/vscodium/releases/download/1.99.0.25073/codium_1.99.0.25073_amd64.deb" -o /tmp/codium.deb
    apt install -y /tmp/codium.deb
    rm -f /tmp/codium.deb
fi

echo "Apps stage complete"
