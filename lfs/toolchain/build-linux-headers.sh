#!/usr/bin/env bash
# Phase 1: Install sanitised Linux kernel headers
set -euo pipefail

source scripts/env.sh

PKG="linux"
VERSION="6.14"
SOURCE_DIR="${LFS}/sources/${PKG}-${VERSION}"

echo "=== Installing Linux ${VERSION} kernel headers ==="

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
make headers
find usr/include -name '.*' -delete
rm -f usr/include/Makefile
cp -rv usr/include "${LFS}/target/usr"

echo "=== Linux ${VERSION} headers installed ==="
