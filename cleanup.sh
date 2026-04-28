#!/bin/bash
set -euo pipefail

if [ -z "${SUDO_USER:-}" ]; then
    echo "This script must be run with sudo: sudo bash install.sh"
    exit 1
fi

# Purge unnecessary packages.
sudo apt autoremove -y

# edit

# Fix network-manager
# Stop and disable services only if they exist – no error if missing
systemctl stop networking.service 2>/dev/null || true
systemctl stop wpa_supplicant.service 2>/dev/null || true
systemctl disable networking.service 2>/dev/null || true
systemctl disable wpa_supplicant.service 2>/dev/null || true

# -----------------------------------------------------------------
# Ensure /etc/network/interfaces only configures loopback,
# so NetworkManager can manage all physical interfaces.
# -----------------------------------------------------------------
INTERFACES_FILE="/etc/network/interfaces"

# Write a safe, minimal loopback-only configuration
cat > "$INTERFACES_FILE" <<'EOF'
# The loopback network interface
auto lo
iface lo inet loopback
EOF

echo "Cleaned /etc/network/interfaces - only loopback remains."

# Release every wireless and wired interface
for iface in $(nmcli -t -f DEVICE,TYPE device status 2>/dev/null | grep -E ':(ethernet|wifi)$' | cut -d: -f1 || true); do
    echo "Releasing $iface ..."
    ip link set "$iface" down
done

systemctl enable --now NetworkManager