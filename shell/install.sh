#!/bin/bash
set -euo pipefail

if [ -z "${SUDO_USER:-}" ]; then
    echo "This script must be run with sudo."
    exit 1
fi

# Install shell and terminal components.
apt install --no-install-recommends -y \
    alacritty \
    tmux \
    zsh \
    fonts-noto-color-emoji

# Install MesloLGS NF fonts for powerlevel10k and Alacritty.
FONT_DIR="/usr/share/fonts/truetype/meslo"
mkdir -p "$FONT_DIR"
curl -fL "https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master/MesloLGS%20NF%20Regular.ttf" -o "$FONT_DIR/MesloLGS NF Regular.ttf"
curl -fL "https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master/MesloLGS%20NF%20Bold.ttf" -o "$FONT_DIR/MesloLGS NF Bold.ttf"
curl -fL "https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master/MesloLGS%20NF%20Italic.ttf" -o "$FONT_DIR/MesloLGS NF Italic.ttf"
curl -fL "https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master/MesloLGS%20NF%20Bold%20Italic.ttf" -o "$FONT_DIR/MesloLGS NF Bold Italic.ttf"
fc-cache -f

echo "Shell stage complete"
