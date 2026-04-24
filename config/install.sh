#!/bin/bash
set -euo pipefail

if [ -z "${SUDO_USER:-}" ]; then
    echo "This script must be run with sudo."
    exit 1
fi

USER_HOME="/home/$SUDO_USER"

# SDDM and display manager configuration.
mkdir -p /etc/sddm.conf.d
printf "[Theme]\nCurrent=breeze\n\n[General]\nDisplayServer=wayland\n" > /etc/sddm.conf.d/setup.conf
systemctl enable sddm

# NetworkManager and bluetooth service configuration.
mkdir -p /etc/NetworkManager/conf.d
printf "[main]\nmanaged=true\n" > /etc/NetworkManager/conf.d/10-globally-managed-devices.conf
systemctl enable bluetooth
systemctl enable NetworkManager

if ! command -v kwriteconfig6 >/dev/null 2>&1; then
    echo "kwriteconfig6 is required for Plasma theme configuration but was not found."
    exit 1
fi

# Plasma desktop layout.
mkdir -p "${USER_HOME}/.config"
cat > "${USER_HOME}/.config/plasma-org.kde.plasma.desktop-appletsrc" << 'EOF'
[ActionPlugins][0]
RightButton;NoModifier=org.kde.contextmenu

[ActionPlugins][1]
RightButton;NoModifier=org.kde.contextmenu

[Containments][1]
ItemGeometries-1280x800=
ItemGeometriesHorizontal=
activityId=118ff4f8-9b09-427f-9097-b9f79e773d72
formfactor=0
immutability=1
lastScreen=0
location=0
plugin=org.kde.plasma.folder
wallpaperplugin=org.kde.color

[Containments][1][General]
positions={"1280x800":[]}

[Containments][1][Wallpaper][org.kde.color][General]
Color=54,60,64

[Containments][2]
activityId=
formfactor=2
immutability=1
lastScreen=0
location=4
plugin=org.kde.panel
wallpaperplugin=org.kde.image

[Containments][2][Applets][16]
immutability=1
plugin=org.kde.plasma.digitalclock

[Containments][2][Applets][16][Configuration]
popupHeight=375
popupWidth=525

[Containments][2][Applets][16][Configuration][Appearance]
fontWeight=400

[Containments][2][Applets][17]
immutability=1
plugin=org.kde.plasma.showdesktop

[Containments][2][Applets][3]
immutability=1
plugin=org.kde.plasma.kickoff

[Containments][2][Applets][3][Configuration]
PreloadWeight=100
popupHeight=492
popupWidth=641

[Containments][2][Applets][3][Configuration][General]
favoritesPortedToKAstats=true

[Containments][2][Applets][4]
immutability=1
plugin=org.kde.plasma.pager

[Containments][2][Applets][5]
immutability=1
plugin=org.kde.plasma.icontasks

[Containments][2][Applets][5][Configuration][General]
launchers=applications:systemsettings.desktop,applications:org.kde.discover.desktop,preferred://filemanager,preferred://browser,applications:codium.desktop,applications:Alacritty.desktop

[Containments][2][Applets][6]
immutability=1
plugin=org.kde.plasma.marginsseparator

[Containments][2][Applets][7]
immutability=1
plugin=org.kde.plasma.systemtray

[Containments][2][Applets][7][Configuration]
PreloadWeight=55
SystrayContainmentId=8

[Containments][2][General]
AppletOrder=3;4;5;6;7;16;17

[Containments][8]
activityId=
formfactor=2
immutability=1
lastScreen=0
location=4
plugin=org.kde.plasma.private.systemtray
popupHeight=432
popupWidth=432
wallpaperplugin=org.kde.image

[Containments][8][Applets][10]
immutability=1
plugin=org.kde.plasma.notifications

[Containments][8][Applets][11]
immutability=1
plugin=org.kde.plasma.devicenotifier

[Containments][8][Applets][12]
immutability=1
plugin=org.kde.plasma.manage-inputmethod

[Containments][8][Applets][13]
immutability=1
plugin=org.kde.plasma.clipboard

[Containments][8][Applets][14]
immutability=1
plugin=org.kde.plasma.volume

[Containments][8][Applets][14][Configuration][General]
migrated=true

[Containments][8][Applets][15]
immutability=1
plugin=org.kde.plasma.cameraindicator

[Containments][8][Applets][18]
immutability=1
plugin=org.kde.plasma.networkmanagement

[Containments][8][Applets][18][Configuration]
PreloadWeight=55

[Containments][8][Applets][9]
immutability=1
plugin=org.kde.plasma.keyboardlayout

[Containments][8][General]
extraItems=org.kde.plasma.keyboardlayout,org.kde.plasma.mediacontroller,org.kde.plasma.networkmanagement,org.kde.plasma.notifications,org.kde.plasma.devicenotifier,org.kde.plasma.bluetooth,org.kde.plasma.manage-inputmethod,org.kde.plasma.clipboard,org.kde.plasma.volume,org.kde.plasma.cameraindicator
knownItems=org.kde.plasma.keyboardlayout,org.kde.plasma.mediacontroller,org.kde.plasma.networkmanagement,org.kde.plasma.notifications,org.kde.plasma.devicenotifier,org.kde.plasma.bluetooth,org.kde.plasma.manage-inputmethod,org.kde.plasma.clipboard,org.kde.plasma.volume,org.kde.plasma.cameraindicator

[ScreenMapping]
itemsOnDisabledScreens=
screenMapping=
EOF

chown "$SUDO_USER:$SUDO_USER" "${USER_HOME}/.config/plasma-org.kde.plasma.desktop-appletsrc"
chown "$SUDO_USER:$SUDO_USER" "${USER_HOME}/.config"

# Plasma theme settings.
sudo -H -u "$SUDO_USER" kwriteconfig6 --file "$USER_HOME/.config/kwinrc" --group org.kde.kdecoration2 --key library "org.kde.kwin.decoration"
sudo -H -u "$SUDO_USER" kwriteconfig6 --file "$USER_HOME/.config/kwinrc" --group org.kde.kdecoration2 --key theme "Plastik"
sudo -H -u "$SUDO_USER" kwriteconfig6 --file "$USER_HOME/.config/kcminputrc" --group Mouse --key cursorTheme "breeze_cursors"
sudo -H -u "$SUDO_USER" kwriteconfig6 --file "$USER_HOME/.config/kwinrc" --group NightLight --key Active "true"
sudo -H -u "$SUDO_USER" kwriteconfig6 --file "$USER_HOME/.config/kwinrc" --group NightLight --key Mode "Custom"
sudo -H -u "$SUDO_USER" kwriteconfig6 --file "$USER_HOME/.config/kwinrc" --group NightLight --key DayTemperature "6500"
sudo -H -u "$SUDO_USER" kwriteconfig6 --file "$USER_HOME/.config/kwinrc" --group NightLight --key NightTemperature "4500"
sudo -H -u "$SUDO_USER" kwriteconfig6 --file "$USER_HOME/.config/kwinrc" --group NightLight --key EveningStart "18:00"
sudo -H -u "$SUDO_USER" kwriteconfig6 --file "$USER_HOME/.config/kwinrc" --group NightLight --key MorningStart "06:00"
sudo -H -u "$SUDO_USER" kwriteconfig6 --file "$USER_HOME/.config/kwinrc" --group NightLight --key TransitionTime "30"

# Disable splash screen.
printf "[KSplash]\nTheme=None\n" | sudo -H -u "$SUDO_USER" tee "$USER_HOME/.config/ksplashrc" > /dev/null

# Shell configuration and dotfiles.
chsh -s "$(which zsh)" "$SUDO_USER"

if [ ! -d "${USER_HOME}/.zprezto" ]; then
    sudo -H -u "$SUDO_USER" git clone --recursive https://github.com/sorin-ionescu/prezto.git "${USER_HOME}/.zprezto"
fi
sudo -H -u "$SUDO_USER" zsh -c 'setopt EXTENDED_GLOB; for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do ln -sf "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"; done'

P10K_PATH="${USER_HOME}/.zprezto/modules/prompt/external/powerlevel10k"
if [ -d "$P10K_PATH" ]; then
    sudo -H -u "$SUDO_USER" rm -rf "$P10K_PATH"
fi
sudo -H -u "$SUDO_USER" git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_PATH"

sudo -H -u "$SUDO_USER" sed -i "s/'prompt'/'syntax-highlighting' 'autosuggestions' 'prompt'/g" "${USER_HOME}/.zpreztorc"
sudo -H -u "$SUDO_USER" sed -i "s/theme 'sorin'/theme 'powerlevel10k'/g" "${USER_HOME}/.zpreztorc"

if ! grep -q 'source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"' "${USER_HOME}/.zshrc" 2>/dev/null; then
cat >> "${USER_HOME}/.zshrc" << 'EOF'
# Source Prezto
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
    source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi
EOF
fi

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

# VS Codium extensions.
if ! command -v codium >/dev/null 2>&1; then
    echo "codium is required for extension install but was not found."
    exit 1
fi

EXTENSIONS="
aaron-bond.better-comments
bmewburn.vscode-intelephense-client
bradlc.vscode-tailwindcss
christian-kohler.npm-intellisense
christian-kohler.path-intellisense
dbaeumer.vscode-eslint
ecmel.vscode-html-css
esbenp.prettier-vscode
formulahendry.auto-close-tag
formulahendry.auto-rename-tag
george-alisson.html-preview-vscode
golang.go
gruntfuggly.todo-tree
llvm-vs-code-extensions.lldb-dap
mads-hartmann.bash-ide-vscode
mariusschulz.yarn-lock-syntax
matthewpi.caddyfile-support
mikestead.dotenv
ms-python.debugpy
ms-python.python
ms-python.vscode-python-envs
ms-vscode.cmake-tools
ms-vscode.powershell
ms-vscode.vscode-typescript-next
pkief.material-icon-theme
rangav.vscode-thunder-client
redhat.java
rust-lang.rust-analyzer
shopify.ruby-lsp
tamasfe.even-better-toml
timonwong.shellcheck
usernamehw.errorlens
vadimcn.vscode-lldb
vscjava.vscode-gradle
vscjava.vscode-java-debug
vscjava.vscode-java-dependency
vscjava.vscode-java-pack
vscjava.vscode-java-test
vscjava.vscode-maven
xdebug.php-debug
"

for EXT in $EXTENSIONS; do
    echo "  Installing extension: $EXT"
    sudo -H -u "$SUDO_USER" codium --install-extension "$EXT" --force 2>/dev/null || true
    sleep 0.2
done

chown -R "$SUDO_USER:$SUDO_USER" "${USER_HOME}/.zprezto" "${USER_HOME}/.zshrc" "${USER_HOME}/.tmux.conf" "${USER_HOME}/.config/alacritty"

echo "Config stage complete"