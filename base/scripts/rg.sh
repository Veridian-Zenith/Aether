#!/usr/bin/env bash
# ripgrep — modern grep replacement
set -euo pipefail
source toolchain/env.sh

PKG="ripgrep"
VERSION="15.1.0"
SDIR="${LFS_SRC}/ripgrep-${VERSION}"

[[ -d "${SDIR}" ]] || {
    mkdir -p "${LFS_SRC}"
    cd "${LFS_SRC}"
    wget "https://github.com/BurntSushi/ripgrep/archive/refs/tags/${VERSION}.tar.gz" -O "ripgrep-${VERSION}.tar.gz"
    tar xf "ripgrep-${VERSION}.tar.gz"
    mv "ripgrep-${VERSION}" "${SDIR}" 2>/dev/null || true
}

cd "${SDIR}"
RUSTFLAGS="-C target-cpu=native -C linker=clang -C link-arg=--target=${LFS_TGT} -C link-arg=--sysroot=${LFS}/target -C link-arg=-fuse-ld=lld" \
cargo build --release --target "${LFS_TGT}"
install -m 755 "target/${LFS_TGT}/release/rg" "${LFS}/target/usr/bin/"

echo "=== ripgrep ${VERSION} complete ==="
