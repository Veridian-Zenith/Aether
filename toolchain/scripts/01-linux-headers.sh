#!/usr/bin/env bash
# Install sanitised Linux headers into target sysroot
set -euo pipefail
source toolchain/env.sh

PKG="linux"
VERSION="6.14"
SDIR="${LFS_SRC}/${PKG}-${VERSION}"

[[ -d "${SDIR}" ]] || {
    mkdir -p "${LFS_SRC}"
    cd "${LFS_SRC}"
    wget "https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-${VERSION}.tar.xz"
    tar xf "linux-${VERSION}.tar.xz"
}

cd "${SDIR}"
make mrproper
make headers
find usr/include -name '.*' -delete
rm -f usr/include/Makefile
cp -rv usr/include "${LFS}/target/usr"

echo "=== Linux ${VERSION} headers installed ==="
