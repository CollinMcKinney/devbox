#!/bin/bash
set -euo pipefail

on_error() {
    local rc=$?
    echo "Install failed (exit $rc) at line $1: $2" >&2
    if [ -r /dev/tty ]; then
        read -r -p "Press Enter to exit..." < /dev/tty
        echo ""
    fi
    exit $rc
}
trap 'on_error "$LINENO" "$BASH_COMMAND"' ERR

if [ -z "${SUDO_USER:-}" ]; then
    echo "This script must be run with sudo: sudo bash install.sh"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

STAGES=(
    "$SCRIPT_DIR/core/install.sh"
    "$SCRIPT_DIR/gui/install.sh"
    "$SCRIPT_DIR/shell/install.sh"
    #"$SCRIPT_DIR/tools/install.sh"
    #"$SCRIPT_DIR/apps/install.sh"
)

for STAGE in "${STAGES[@]}"; do
    echo ""
    echo "=========================================="
    echo "Running stage: ${STAGE##*/}"
    echo "=========================================="
    bash "$STAGE"
done

echo ""
echo "=========================================="
echo "Installation complete!"
echo ""
echo "To verify installations:"
echo "  dpkg -l | grep -E '(codium|podman|docker)'"
echo "  which codium podman docker"
echo ""
echo "Plasma configuration has been applied."
echo "=========================================="
echo ""
REPLY=""
if [ -r /dev/tty ]; then
    read -p "Reboot now? [y/N] " -n 1 -r < /dev/tty
fi
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Rebooting..."
    reboot
else
    echo "Done! Please remember to reboot later to apply all changes."
fi
