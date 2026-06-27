#!/usr/bin/env bash
# systemd — init system
set -euo pipefail
source toolchain/env.sh

PKG="systemd"
VERSION="261"
SDIR="${LFS_SRC}/${PKG}-${VERSION}"
BDIR="${SDIR}/build"

[[ -d "${SDIR}" ]] || {
    mkdir -p "${LFS_SRC}"
    cd "${LFS_SRC}"
    wget "https://github.com/systemd/systemd/archive/refs/tags/v${VERSION}.tar.gz" -O "systemd-${VERSION}.tar.gz"
    tar xf "systemd-${VERSION}.tar.gz"
}

mkdir -p "${BDIR}"
cd "${BDIR}"

CC=clang CXX=clang++ \
cmake "${SDIR}" \
    -G Ninja \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_C_FLAGS="--target=${LFS_TGT} --sysroot=${LFS}/target -O2 -pipe" \
    -DCMAKE_CXX_FLAGS="--target=${LFS_TGT} --sysroot=${LFS}/target -O2 -pipe" \
    -DCMAKE_SYSROOT="${LFS}/target" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_SKIP_RPATH=ON \
    -DSYSTEMD_LOG_LEVEL=info \
    -Durl_libcurl=disabled \
    -Dfirst-boot-full-preset=enabled

ninja -j$(nproc)
ninja install DESTDIR="${LFS}/target"

echo "=== systemd ${VERSION} complete ==="
