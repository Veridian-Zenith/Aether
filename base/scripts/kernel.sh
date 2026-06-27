#!/usr/bin/env bash
# CachyOS-patched Linux kernel — compiled with clang+lld+LTO
set -euo pipefail
source toolchain/env.sh

PKG="linux"
VER="6.14"
SDIR="${LFS_SRC}/${PKG}-${VER}"

echo "=== Building CachyOS kernel ${VER} ==="

# Fetch kernel source
[[ -d "${SDIR}" ]] || {
    mkdir -p "${LFS_SRC}"
    cd "${LFS_SRC}"
    wget "https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-${VER}.tar.xz"
    tar xf "linux-${VER}.tar.xz"
}

cd "${SDIR}"
make mrproper

# Apply CachyOS patches
PATCHDIR="${PROJECT_SOURCE_DIR}/base/kernel/patches"
if [[ -d "${PATCHDIR}" && "$(ls -A ${PATCHDIR})" ]]; then
    for p in "${PATCHDIR}"/*.patch; do
        echo "Applying patch: $(basename ${p})"
        patch -Np1 < "${p}"
    done
fi

# Use host kernel config as base (CachyOS optimised)
HOST_CONFIG="/boot/config-7.1.1-1-cachyos-eevdf-lto"
if [[ -f "${HOST_CONFIG}" ]]; then
    cp "${HOST_CONFIG}" .config
    make olddefconfig
elif [[ -f "${PROJECT_SOURCE_DIR}/config/kernel.config" ]]; then
    cp "${PROJECT_SOURCE_DIR}/config/kernel.config" .config
    make olddefconfig
else
    make localmodconfig
fi

# Set Aether local version
scripts/config --set-str CONFIG_LOCALVERSION "-aether"
scripts/config --disable CONFIG_LOCALVERSION_AUTO

# Enable EEVDF / BORE if available
scripts/config --enable CONFIG_SCHED_EEVDF 2>/dev/null || true
scripts/config --enable CONFIG_SCHED_BORE 2>/dev/null || true

# Build with LLVM
make CC=clang LD=ld.lld AR=llvm-ar NM=llvm-nm \
     OBJCOPY=llvm-objcopy OBJDUMP=llvm-objdump \
     STRIP=llvm-strip READELF=llvm-readelf \
     HOSTCC=clang HOSTCXX=clang++ HOSTLD=ld.lld \
     LLVM=1 LLVM_IAS=1 \
     -j$(nproc) bzImage modules

# Install
make modules_install INSTALL_MOD_PATH="${LFS}/target"
cp -v arch/x86_64/boot/bzImage "${LFS}/target/boot/vmlinuz-${VER}-aether"
cp -v System.map "${LFS}/target/boot/System.map-${VER}-aether"
cp -v .config "${LFS}/target/boot/config-${VER}-aether"

echo "=== CachyOS kernel ${VER} complete ==="
