#!/usr/bin/env bash
# eza — modern ls replacement
set -euo pipefail
source toolchain/env.sh

PKG="eza"
VERSION="0.20.19"
SDIR="${LFS_SRC}/eza-${VERSION}"

[[ -d "${SDIR}" ]] || {
    mkdir -p "${LFS_SRC}"
    cd "${LFS_SRC}"
    wget "https://github.com/eza-community/eza/archive/refs/tags/v${VERSION}.tar.gz" -O "eza-${VERSION}.tar.gz"
    tar xf "eza-${VERSION}.tar.gz"
    mv "eza-${VERSION}" "${SDIR}" 2>/dev/null || true
}

cd "${SDIR}"
RUSTFLAGS="-C target-cpu=native -C linker=clang -C link-arg=--target=${LFS_TGT} -C link-arg=--sysroot=${LFS}/target -C link-arg=-fuse-ld=lld" \
cargo build --release --target "${LFS_TGT}"
install -m 755 "target/${LFS_TGT}/release/eza" "${LFS}/target/usr/bin/"

echo "=== eza ${VERSION} complete ==="
