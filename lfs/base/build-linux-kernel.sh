#!/usr/bin/env bash
# Base system: Linux kernel — custom build for host hardware
set -euo pipefail

source scripts/env.sh

PKG="linux"
VERSION="6.14"
SOURCE_DIR="${LFS}/sources/${PKG}-${VERSION}"

echo "=== Building Linux kernel ${VERSION} ==="

mkdir -p "${LFS}/sources"
if [ ! -d "${SOURCE_DIR}" ]; then
    cd "${LFS}/sources"
    if [ ! -f "linux-${VERSION}.tar.xz" ]; then
        wget "https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-${VERSION}.tar.xz"
    fi
    tar xf "linux-${VERSION}.tar.xz"
fi

cd "${SOURCE_DIR}"
make mrproper

# Use a config optimized for the build host
if [ -f "${PROJECT_SOURCE_DIR}/config/kernel/kernel.config" ]; then
    cp "${PROJECT_SOURCE_DIR}/config/kernel/kernel.config" .config
else
    # Generate a host-optimized config
    make localmodconfig
    # Save for future builds
    cp .config "${PROJECT_SOURCE_DIR}/config/kernel/kernel.config"
fi

# Apply hardware-specific optimizations
scripts/config --set-str CONFIG_LOCALVERSION "-aether"

make -j$(nproc) bzImage modules

# Install modules
make modules_install INSTALL_MOD_PATH="${LFS}/target"

# Install kernel image
cp -v arch/x86_64/boot/bzImage "${LFS}/target/boot/vmlinuz-${VERSION}-aether"
cp -v System.map "${LFS}/target/boot/System.map-${VERSION}-aether"
cp -v .config "${LFS}/target/boot/config-${VERSION}-aether"

echo "=== Linux kernel ${VERSION} installed ==="
