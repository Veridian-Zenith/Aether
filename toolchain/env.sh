#!/usr/bin/env bash
# LLVM toolchain environment for cross-compilation
set -a

LFS="$(realpath rootfs)"
LFS_TGT="x86_64-linux-gnu"
LFS_SRC="${LFS}/../packages/sources"

# Host LLVM toolchain (cross-compiler)
export CC=clang
export CXX=clang++
export LD=ld.lld
export AS=clang
export AR=llvm-ar
export NM=llvm-nm
export RANLIB=llvm-ranlib
export STRIP=llvm-strip
export OBJCOPY=llvm-objcopy
export OBJDUMP=llvm-objdump
export READELF=llvm-readelf

# Target flags for Alder Lake
TGT_CFLAGS="-march=native -O3 -pipe -fno-plt -rtlib=compiler-rt -unwindlib=libunwind -fstack-protector-strong -D_FORTIFY_SOURCE=3"
TGT_LDFLAGS="-fuse-ld=lld -Wl,-O1,--as-needed,-z,relro,-z,now -rtlib=compiler-rt -unwindlib=libunwind"

export CFLAGS="${TGT_CFLAGS} --sysroot=${LFS}/target"
export CXXFLAGS="${TGT_CFLAGS} --sysroot=${LFS}/target"
export LDFLAGS="${TGT_LDFLAGS} --sysroot=${LFS}/target"
export MAKEFLAGS="-j$(nproc)"

# Cross-compilation path
export PATH="${LFS}/cross-tools/bin:${LFS}/target/usr/bin:${PATH}"
export PKG_CONFIG_LIBDIR="${LFS}/target/usr/lib/pkgconfig:${LFS}/target/usr/share/pkgconfig"
export PKG_CONFIG_SYSROOT_DIR="${LFS}/target"

set +a
