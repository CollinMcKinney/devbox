#!/bin/bash
set -euo pipefail

if [ -z "${SUDO_USER:-}" ]; then
    echo "This script must be run with sudo."
    exit 1
fi

USER_HOME="/home/$SUDO_USER"

# GPU detection and driver install.
GPU_TYPE=$(lspci | grep -E "VGA|3D" | tr '[:upper:]' '[:lower:]')

if [[ $GPU_TYPE == *"nvidia"* ]]; then
    apt install --no-install-recommends -y \
        nvidia-driver \
        nvidia-settings \
        firmware-misc-nonfree \
        linux-headers-amd64
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

mkdir -p /etc/sddm.conf.d
printf "[Theme]\nCurrent=breeze\n\n[General]\nDisplayServer=wayland\n" > /etc/sddm.conf.d/setup.conf
systemctl enable sddm

# Plasma desktop.
apt install --no-install-recommends -y \
    plasma-desktop \
    plasma-workspace \
    kwin-wayland \
    xdg-desktop-portal-kde \
    libqt6svg6 \
    libxcb-cursor0 \
    plasma-discover

# Networking and audio stack.
apt install --no-install-recommends -y \
    network-manager \
    plasma-nm \
    bluez \
    bluedevil \
    plasma-pa \
    pipewire-audio \
    libspa-0.2-bluetooth

mkdir -p /etc/NetworkManager/conf.d
printf "[main]\nmanaged=true\n" > /etc/NetworkManager/conf.d/10-globally-managed-devices.conf
systemctl enable bluetooth
systemctl enable NetworkManager

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

# Theme settings.
sudo -u "$SUDO_USER" kwriteconfig6 --file ~/.config/kwinrc --group org.kde.kdecoration2 --key library "org.kde.kwin.decoration"
sudo -u "$SUDO_USER" kwriteconfig6 --file ~/.config/kwinrc --group org.kde.kdecoration2 --key theme "Plastik"
sudo -u "$SUDO_USER" kwriteconfig6 --file ~/.config/kcminputrc --group Mouse --key cursorTheme "breeze_cursors"
sudo -u "$SUDO_USER" kwriteconfig6 --file ~/.config/kwinrc --group NightLight --key Active "true"
sudo -u "$SUDO_USER" kwriteconfig6 --file ~/.config/kwinrc --group NightLight --key Mode "Custom"
sudo -u "$SUDO_USER" kwriteconfig6 --file ~/.config/kwinrc --group NightLight --key DayTemperature "6500"
sudo -u "$SUDO_USER" kwriteconfig6 --file ~/.config/kwinrc --group NightLight --key NightTemperature "4500"
sudo -u "$SUDO_USER" kwriteconfig6 --file ~/.config/kwinrc --group NightLight --key EveningStart "18:00"
sudo -u "$SUDO_USER" kwriteconfig6 --file ~/.config/kwinrc --group NightLight --key MorningStart "06:00"
sudo -u "$SUDO_USER" kwriteconfig6 --file ~/.config/kwinrc --group NightLight --key TransitionTime "30"

# Disable splash screen.
sudo -u "$SUDO_USER" mkdir -p "$USER_HOME/.config"
printf "[KSplash]\nTheme=None\n" | sudo -u "$SUDO_USER" tee "$USER_HOME/.config/ksplashrc" > /dev/null

echo "GUI stage complete"