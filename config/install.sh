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

# Ensure zsh is the user's login shell (dotfiles alone do not change this).
if command -v zsh >/dev/null 2>&1; then
    chsh -s "$(command -v zsh)" "$SUDO_USER"
else
    echo "Warning: zsh is not installed; login shell left unchanged."
fi

# Set Alacritty as the system default terminal emulator.
if command -v alacritty >/dev/null 2>&1; then
    if command -v update-alternatives >/dev/null 2>&1; then
        if update-alternatives --query x-terminal-emulator >/dev/null 2>&1; then
            update-alternatives --set x-terminal-emulator "$(command -v alacritty)"
        else
            update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator "$(command -v alacritty)" 60
            update-alternatives --set x-terminal-emulator "$(command -v alacritty)"
        fi
    else
        echo "Warning: update-alternatives not found; system terminal default unchanged."
    fi
else
    echo "Warning: alacritty is not installed; system terminal default unchanged."
fi

# Install Prezto and Powerlevel10k if missing.
if [ ! -d "$USER_HOME/.zprezto" ]; then
    sudo -H -u "$SUDO_USER" git clone --recursive https://github.com/sorin-ionescu/prezto.git "$USER_HOME/.zprezto"
fi

if [ ! -d "$USER_HOME/.zprezto/modules/prompt/external/powerlevel10k" ]; then
    sudo -H -u "$SUDO_USER" mkdir -p "$USER_HOME/.zprezto/modules/prompt/external"
    sudo -H -u "$SUDO_USER" git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$USER_HOME/.zprezto/modules/prompt/external/powerlevel10k"
fi

# Ensure .zshrc sources Prezto.
if ! grep -q 'source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"' "$USER_HOME/.zshrc" 2>/dev/null; then
cat >> "$USER_HOME/.zshrc" << 'EOF'
# Source Prezto
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
    source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi
EOF
fi

# Ensure copied files are owned by the target user.
for PATH_TO_FIX in ".config" ".local" ".tmux.conf" ".zpreztorc" ".zshrc" ".zprezto"; do
    if [ -e "$USER_HOME/$PATH_TO_FIX" ]; then
        chown -R "$SUDO_USER:$SUDO_USER" "$USER_HOME/$PATH_TO_FIX"
    fi
done

echo "Config stage complete (dotfiles copied)"
