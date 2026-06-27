#!/usr/bin/env bash
# fd — modern find replacement
set -euo pipefail
source toolchain/env.sh

PKG="fd"
VERSION="10.4.2"
SDIR="${LFS_SRC}/fd-${VERSION}"

[[ -d "${SDIR}" ]] || {
    mkdir -p "${LFS_SRC}"
    cd "${LFS_SRC}"
    wget "https://github.com/sharkdp/fd/archive/refs/tags/v${VERSION}.tar.gz" -O "fd-${VERSION}.tar.gz"
    tar xf "fd-${VERSION}.tar.gz"
    mv "fd-${VERSION}" "${SDIR}" 2>/dev/null || true
}

cd "${SDIR}"
RUSTFLAGS="-C target-cpu=native -C linker=clang -C link-arg=--target=${LFS_TGT} -C link-arg=--sysroot=${LFS}/target -C link-arg=-fuse-ld=lld" \
cargo build --release --target "${LFS_TGT}"
install -m 755 "target/${LFS_TGT}/release/fd" "${LFS}/target/usr/bin/"

echo "=== fd ${VERSION} complete ==="
