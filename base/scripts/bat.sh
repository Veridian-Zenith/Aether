#!/usr/bin/env bash
# bat — modern cat replacement with syntax highlighting
set -euo pipefail
source toolchain/env.sh

PKG="bat"
VERSION="0.25.0"
SDIR="${LFS_SRC}/bat-${VERSION}"

[[ -d "${SDIR}" ]] || {
    mkdir -p "${LFS_SRC}"
    cd "${LFS_SRC}"
    wget "https://github.com/sharkdp/bat/archive/refs/tags/v${VERSION}.tar.gz" -O "bat-${VERSION}.tar.gz"
    tar xf "bat-${VERSION}.tar.gz"
    mv "bat-${VERSION}" "${SDIR}" 2>/dev/null || true
}

cd "${SDIR}"
RUSTFLAGS="-C target-cpu=native -C linker=clang -C link-arg=--target=${LFS_TGT} -C link-arg=--sysroot=${LFS}/target -C link-arg=-fuse-ld=lld" \
cargo build --release --target "${LFS_TGT}"
install -m 755 "target/${LFS_TGT}/release/bat" "${LFS}/target/usr/bin/"

echo "=== bat ${VERSION} complete ==="
