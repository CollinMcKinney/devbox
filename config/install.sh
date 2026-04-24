#!/bin/bash
set -euo pipefail

if [ -z "${SUDO_USER:-}" ]; then
    echo "This script must be run with sudo."
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$SCRIPT_DIR/dotfiles"
USER_HOME="/home/$SUDO_USER"

if [ ! -d "$DOTFILES_DIR" ]; then
    echo "Dotfiles directory not found: $DOTFILES_DIR"
    exit 1
fi

# Copy the full dotfiles tree into the target user's home directory.
cp -a "$DOTFILES_DIR"/. "$USER_HOME"/

# Ensure copied files are owned by the target user.
for PATH_TO_FIX in ".config" ".local" ".tmux.conf" ".zpreztorc" ".zshrc"; do
    if [ -e "$USER_HOME/$PATH_TO_FIX" ]; then
        chown -R "$SUDO_USER:$SUDO_USER" "$USER_HOME/$PATH_TO_FIX"
    fi
done

echo "Config stage complete (dotfiles copied)"
