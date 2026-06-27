#!/usr/bin/env bash
# Temporary: m4 (required by many tools)
set -euo pipefail
source toolchain/env.sh

PKG="m4"
VERSION="1.4.19"
SDIR="${LFS_SRC}/${PKG}-${VERSION}"

[[ -d "${SDIR}" ]] || {
    mkdir -p "${LFS_SRC}"
    cd "${LFS_SRC}"
    wget "https://ftp.gnu.org/gnu/m4/m4-${VERSION}.tar.xz"
    tar xf "m4-${VERSION}.tar.xz"
}

cd "${SDIR}"
CC=clang \
CFLAGS="--target=${LFS_TGT} --sysroot=${LFS}/target -O2" \
LDFLAGS="--target=${LFS_TGT} --sysroot=${LFS}/target -fuse-ld=lld" \
./configure \
    --prefix=/usr \
    --host="${LFS_TGT}" \
    --build="$(uname -m)-linux-gnu"

make -j$(nproc)
make DESTDIR="${LFS}/target" install

echo "=== m4 ${VERSION} complete ==="
