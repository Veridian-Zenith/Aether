#!/usr/bin/env bash
# Temporary: dash — minimal POSIX sh (for chroot scripts, not interactive)
set -euo pipefail
source toolchain/env.sh

PKG="dash"
VERSION="0.5.12"
SDIR="${LFS_SRC}/${PKG}-${VERSION}"

[[ -d "${SDIR}" ]] || {
    mkdir -p "${LFS_SRC}"
    cd "${LFS_SRC}"
    wget "http://gondor.apana.org.au/~herbert/dash/files/dash-${VERSION}.tar.gz"
    tar xf "dash-${VERSION}.tar.gz"
}

cd "${SDIR}"
CC=clang \
CFLAGS="--target=${LFS_TGT} --sysroot=${LFS}/target -O2 -pipe" \
LDFLAGS="--target=${LFS_TGT} --sysroot=${LFS}/target -fuse-ld=lld" \
./configure \
    --prefix=/usr \
    --host="${LFS_TGT}" \
    --build="$(uname -m)-linux-gnu" \
    --bindir=/bin

make -j$(nproc)
make DESTDIR="${LFS}/target" install

ln -sfv dash "${LFS}/target/bin/sh"

echo "=== dash ${VERSION} complete ==="
