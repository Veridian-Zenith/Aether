#!/usr/bin/env bash
# Temporary: fish shell (default interactive shell for Aether)
set -euo pipefail
source toolchain/env.sh

PKG="fish"
VERSION="4.7.1"
SDIR="${LFS_SRC}/${PKG}-${VERSION}"

[[ -d "${SDIR}" ]] || {
    mkdir -p "${LFS_SRC}"
    cd "${LFS_SRC}"
    wget "https://github.com/fish-shell/fish-shell/releases/download/${VERSION}/fish-${VERSION}.tar.xz"
    tar xf "fish-${VERSION}.tar.xz"
}

BDIR="${SDIR}/build"
mkdir -p "${BDIR}"
cd "${BDIR}"

CC=clang CXX=clang++ \
cmake "${SDIR}" \
    -G Ninja \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_INSTALL_PREFIX="${LFS}/target/usr" \
    -DCMAKE_C_FLAGS="--target=${LFS_TGT} --sysroot=${LFS}/target -O2 -pipe" \
    -DCMAKE_CXX_FLAGS="--target=${LFS_TGT} --sysroot=${LFS}/target -O2 -pipe" \
    -DCMAKE_EXE_LINKER_FLAGS="-fuse-ld=lld" \
    -DCMAKE_SYSROOT="${LFS}/target" \
    -DCMAKE_BUILD_TYPE=Release \
    -DFISH_USE_SYSTEM_PCRE2=OFF \
    -DMACOS_CODE_SIGNING=OFF

ninja -j$(nproc)
ninja install

# Make fish the default login shell (must exist in /etc/shells)
mkdir -p "${LFS}/target/etc"
echo "/usr/bin/fish" >> "${LFS}/target/etc/shells"

echo "=== fish ${VERSION} complete ==="
