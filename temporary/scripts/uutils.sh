#!/usr/bin/env bash
# Temporary: uutils — Rust coreutils (replaces GNU coreutils)
set -euo pipefail
source toolchain/env.sh

PKG="uutils"
VERSION="0.0.29"
SDIR="${LFS_SRC}/coreutils-${VERSION}"

[[ -d "${SDIR}" ]] || {
    mkdir -p "${LFS_SRC}"
    cd "${LFS_SRC}"
    git clone --depth 1 --branch "${VERSION}" https://github.com/uutils/coreutils.git "${SDIR}"
}

cd "${SDIR}"

# Build with Rust cross-compilation for the target
RUSTFLAGS="-C target-cpu=native -C linker=clang -C link-arg=--target=${LFS_TGT} -C link-arg=--sysroot=${LFS}/target -C link-arg=-fuse-ld=lld" \
cargo build --release --target "${LFS_TGT}"

install -dv "${LFS}/target/usr/bin"
for bin in target/${LFS_TGT}/release/uutils; do
    install -m 755 "${bin}" "${LFS}/target/usr/bin/"
done

# Create symlinks for each utility
for util in cat cp mkdir mv rm touch chmod chown ls head tail sort uniq wc; do
    ln -sfv uutils "${LFS}/target/usr/bin/${util}"
done

echo "=== uutils ${VERSION} complete ==="
