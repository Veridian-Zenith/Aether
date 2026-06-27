#!/usr/bin/env bash
# Temporary: mold — fast linker (replaces lld for host builds)
set -euo pipefail
source toolchain/env.sh

PKG="mold"
VERSION="2.36.0"
SDIR="${LFS_SRC}/mold-${VERSION}"

[[ -d "${SDIR}" ]] || {
    mkdir -p "${LFS_SRC}"
    cd "${LFS_SRC}"
    wget "https://github.com/rui314/mold/archive/refs/tags/v${VERSION}.tar.gz" -O "mold-${VERSION}.tar.gz"
    tar xf "mold-${VERSION}.tar.gz"
}

BDIR="${SDIR}/build"
mkdir -p "${BDIR}"
cd "${BDIR}"

CC=clang CXX=clang++ \
cmake "${SDIR}" \
    -G Ninja \
    -DCMAKE_INSTALL_PREFIX="${LFS}/cross-tools" \
    -DCMAKE_BUILD_TYPE=Release \
    -DMOLD_LTO=ON \
    -DMOLD_USE_MOLD=ON \
    -DMOLD_USE_LLVM_LIBCXX=ON

ninja -j$(nproc)
ninja install

echo "=== mold ${VERSION} complete ==="
