#!/bin/bash
set -euo pipefail

if [ -z "${SUDO_USER:-}" ]; then
    echo "This script must be run with sudo."
    exit 1
fi

USER_HOME="/home/$SUDO_USER"

# Install shell and terminal components.
apt install --no-install-recommends -y \
    alacritty \
    tmux \
    zsh \
    fonts-noto-color-emoji

# Set zsh as default shell.
chsh -s "$(which zsh)" "$SUDO_USER"

# Install Prezto and create runcom symlinks.
sudo -u "$SUDO_USER" git clone --recursive https://github.com/sorin-ionescu/prezto.git "${USER_HOME}/.zprezto"
sudo -u "$SUDO_USER" zsh -c 'setopt EXTENDED_GLOB; for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do ln -sf "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"; done'

# Install Powerlevel10k theme.
P10K_PATH="${USER_HOME}/.zprezto/modules/prompt/external/powerlevel10k"
if [ -d "$P10K_PATH" ]; then
    sudo -u "$SUDO_USER" rm -rf "$P10K_PATH"
fi
sudo -u "$SUDO_USER" git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_PATH"

sudo -u "$SUDO_USER" sed -i "s/'prompt'/'syntax-highlighting' 'autosuggestions' 'prompt'/g" "${USER_HOME}/.zpreztorc"
sudo -u "$SUDO_USER" sed -i "s/theme 'sorin'/theme 'powerlevel10k'/g" "${USER_HOME}/.zpreztorc"

cat >> "${USER_HOME}/.zshrc" << 'EOF'
# Source Prezto
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
    source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi
EOF

mkdir -p "${USER_HOME}/.config/alacritty"
cat > "${USER_HOME}/.config/alacritty/alacritty.toml" << 'EOF'
[window]
padding = { x = 10, y = 10 }
dynamic_padding = true

[font]
size = 11

[font.normal]
family = "MesloLGS NF"
style = "Regular"

[font.bold]
family = "MesloLGS NF"
style = "Bold"

[font.italic]
family = "MesloLGS NF"
style = "Italic"

[font.bold_italic]
family = "MesloLGS NF"
style = "Bold Italic"

[shell]
program = "/usr/bin/tmux"
args = ["new-session", "-A", "-s", "main"]
EOF

cat > "${USER_HOME}/.tmux.conf" << 'EOF'
# Set prefix to Ctrl-a (easier than Ctrl-b)
unbind C-b
set -g prefix C-a
bind C-a send-prefix

# Start windows and panes at 1, not 0
set -g base-index 1
set -g pane-base-index 1

# Mouse support
set -g mouse on

# Faster command sequencing
set -sg escape-time 0

# Increase scrollback buffer
set -g history-limit 50000

# Vi mode for copy mode
setw -g mode-keys vi

# Better colors
set -g default-terminal "screen-256color"

# Reload config
bind r source-file ~/.tmux.conf \; display "Config reloaded!"

# Status bar
set -g status-bg black
set -g status-fg white
set -g status-left "[#S] "
set -g status-right "%H:%M"
EOF

# Install MesloLGS NF fonts for powerlevel10k and Alacritty.
FONT_DIR="/usr/share/fonts/truetype/meslo"
mkdir -p "$FONT_DIR"
curl -fL "https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master/MesloLGS%20NF%20Regular.ttf" -o "$FONT_DIR/MesloLGS NF Regular.ttf"
curl -fL "https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master/MesloLGS%20NF%20Bold.ttf" -o "$FONT_DIR/MesloLGS NF Bold.ttf"
curl -fL "https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master/MesloLGS%20NF%20Italic.ttf" -o "$FONT_DIR/MesloLGS NF Italic.ttf"
curl -fL "https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master/MesloLGS%20NF%20Bold%20Italic.ttf" -o "$FONT_DIR/MesloLGS NF Bold Italic.ttf"
fc-cache -f

chown -R "$SUDO_USER:$SUDO_USER" "${USER_HOME}/.zprezto" "${USER_HOME}/.zshrc" "${USER_HOME}/.tmux.conf" "${USER_HOME}/.config/alacritty"

echo "Shell stage complete"