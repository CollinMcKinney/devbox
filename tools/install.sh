#!/bin/bash
set -euo pipefail

if [ -z "${SUDO_USER:-}" ]; then
    echo "This script must be run with sudo."
    exit 1
fi

USER_HOME="/home/$SUDO_USER"

# Compilers, runtimes, and debuggers.
apt install -y \
    clang \
    cmake \
    gdb \
    golang-go \
    default-jdk \
    maven \
    nodejs \
    npm \
    php \
    php-cli \
    php-mbstring \
    php-xml \
    python3 \
    python3-pip \
    python3-venv \
    ruby-full \
    emscripten \
    wabt \
    binaryen

# TODO: install gradle without installing groovyConsole.

# Latest stable Node via n.
npm install -g n
n stable
corepack enable

# Rust toolchain.
sudo -u "$SUDO_USER" sh -c 'curl https://sh.rustup.rs -sSf | sh -s -- -y'
sudo -u "$SUDO_USER" "$USER_HOME/.cargo/bin/rustup" target add wasm32-unknown-unknown wasm32-wasip1

# .NET SDK.
DEBIAN_MAJOR="$(awk -F= '/^VERSION_ID=/{gsub(/"/,"",$2);split($2,a,".");print a[1]}' /etc/os-release)"
curl -fsSL "https://packages.microsoft.com/config/debian/${DEBIAN_MAJOR}/packages-microsoft-prod.deb" -o /tmp/packages-microsoft-prod.deb
dpkg -i /tmp/packages-microsoft-prod.deb
apt update
if apt-cache show dotnet-sdk-10.0 >/dev/null 2>&1; then
    apt install -y dotnet-sdk-10.0
elif apt-cache show dotnet-sdk-9.0 >/dev/null 2>&1; then
    apt install -y dotnet-sdk-9.0
else
    apt install -y dotnet-sdk-8.0
fi
rm -f /tmp/packages-microsoft-prod.deb

# Zig when available.
if apt-cache show zig >/dev/null 2>&1; then
    apt install -y zig
fi

# Wasmtime with backports preference.
VERSION_CODENAME="$(awk -F= '/^VERSION_CODENAME=/{gsub(/"/,"",$2);print $2}' /etc/os-release)"
if [ -n "$VERSION_CODENAME" ] && [ ! -f /etc/apt/sources.list.d/backports.sources ]; then
    printf "Types: deb\nURIs: http://deb.debian.org/debian\nSuites: %s-backports\nComponents: main contrib non-free non-free-firmware\nSigned-By: /usr/share/keyrings/debian-archive-keyring.gpg\n" "$VERSION_CODENAME" > /etc/apt/sources.list.d/backports.sources
    apt update
fi
if [ -n "$VERSION_CODENAME" ] && apt-cache -t "${VERSION_CODENAME}-backports" show wasmtime >/dev/null 2>&1; then
    apt install -y -t "${VERSION_CODENAME}-backports" wasmtime
elif apt-cache show wasmtime >/dev/null 2>&1; then
    apt install -y wasmtime
fi

# Docker engine and plugins.
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc
printf "Types: deb\nURIs: https://download.docker.com/linux/debian\nSuites: %s\nComponents: stable\nArchitectures: %s\nSigned-By: /etc/apt/keyrings/docker.asc\n" "$VERSION_CODENAME" "$(dpkg --print-architecture)" > /etc/apt/sources.list.d/docker.sources
apt update
apt install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin
usermod -aG docker "$SUDO_USER"

# Docker Desktop.
# echo "Installing Docker Desktop..."
# curl -fL "https://desktop.docker.com/linux/main/amd64/docker-desktop-amd64.deb" -o /tmp/docker-desktop-amd64.deb
# apt install -y /tmp/docker-desktop-amd64.deb
# rm -f /tmp/docker-desktop-amd64.deb
# usermod -aG kvm "$SUDO_USER" 2>/dev/null

# Podman.
apt install -y podman podman-compose

# Runtime helper.
cat > /usr/local/bin/container-runtime << 'EOF'
#!/bin/bash
# Usage: container-runtime [build|run|push|pull|...]
if command -v docker &> /dev/null && [ -z "${USE_PODMAN:-}" ]; then
    exec docker "$@"
elif command -v podman &> /dev/null; then
    exec podman "$@"
else
    echo "Neither Docker nor Podman found" >&2
    exit 1
fi
EOF
chmod +x /usr/local/bin/container-runtime

echo "Tools stage complete"