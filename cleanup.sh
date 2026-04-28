#!/bin/bash
set -euo pipefail

# Purge unnecessary packages.
sudo apt autoremove -y

# Fix network-manager
# Stop and disable services only if they exist – no error if missing
systemctl stop networking.service 2>/dev/null || true
systemctl stop wpa_supplicant.service 2>/dev/null || true
systemctl disable networking.service 2>/dev/null || true
systemctl disable wpa_supplicant.service 2>/dev/null || true

# Release every wireless and wired interface
for iface in $(nmcli -t -f DEVICE,TYPE device status 2>/dev/null | grep -E ':(ethernet|wifi)$' | cut -d: -f1 || true); do
    echo "Releasing $iface ..."
    ip link set "$iface" down
done

systemctl enable --now NetworkManager