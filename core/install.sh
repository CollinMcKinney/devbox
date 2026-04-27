#!/bin/bash
set -euo pipefail

if [ -z "${SUDO_USER:-}" ]; then
    echo "This script must be run with sudo."
    exit 1
fi

# Enable non-free and contrib, then update apt.
if [ -f /etc/apt/sources.list ]; then
    sed -i 's/main$/main contrib non-free non-free-firmware/g' /etc/apt/sources.list
fi
for SOURCES_FILE in /etc/apt/sources.list.d/*.sources; do
    [ -f "$SOURCES_FILE" ] || continue
    sed -i -E '/^Components:/ {
        /contrib/! s/$/ contrib/;
        /non-free([[:space:]]|$)/! s/$/ non-free/;
        /non-free-firmware/! s/$/ non-free-firmware/;
    }' "$SOURCES_FILE"
done

if ! grep -RqsE '(^deb .* (contrib|non-free|non-free-firmware))|(^Components:.*(contrib|non-free|non-free-firmware))' \
    /etc/apt/sources.list /etc/apt/sources.list.d 2>/dev/null; then
    echo "Warning: Could not verify contrib/non-free/non-free-firmware in apt sources."
fi
apt update

# Core utilities used across multiple stages.
apt install --no-install-recommends -y \
    build-essential \
    curl \
    pciutils \
    git \
    libwebkit2gtk-4.1-dev \
    libxdo-dev \
    libssl-dev \
    libayatana-appindicator3-dev \
    librsvg2-dev \
    file \
    wget \
    zip \
    micro \
    desktop-file-utils \
    ca-certificates