#!/bin/bash
set -euo pipefail

if [ -z "${SUDO_USER:-}" ]; then
    echo "This script must be run with sudo."
    exit 1
fi

# Desktop applications and media codecs.
apt install --no-install-recommends -y \
    firefox-esr \
    htop \
    dolphin \
    konsole-kpart \
    ffmpeg \
    libavcodec-extra

# VS Codium.
echo "Installing VS Codium (native .deb)..."
CODIUM_LATEST=$(curl -s https://api.github.com/repos/VSCodium/vscodium/releases/latest | grep "browser_download_url.*amd64.deb" | grep -v "riscv64" | head -1 | cut -d '"' -f 4)

if [ -n "$CODIUM_LATEST" ]; then
    echo "Downloading Codium from: $CODIUM_LATEST"
    curl -fL "$CODIUM_LATEST" -o /tmp/codium.deb
    apt install -y /tmp/codium.deb
    rm -f /tmp/codium.deb
else
    echo "Failed to get latest Codium version, trying fallback..."
    curl -fL "https://github.com/VSCodium/vscodium/releases/download/1.99.0.25073/codium_1.99.0.25073_amd64.deb" -o /tmp/codium.deb
    apt install -y /tmp/codium.deb
    rm -f /tmp/codium.deb
fi

# VS Codium extensions.
echo "Installing VS Codium extensions..."
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
    echo "  Installing: $EXT"
    sudo -H -u "$SUDO_USER" codium --install-extension "$EXT" --force 2>/dev/null || true
    sleep 0.2
done

echo "Apps stage complete"
