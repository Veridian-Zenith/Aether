#!/usr/bin/env bash
# LLVM/clang for target — full toolchain self-hosting
set -euo pipefail
source toolchain/env.sh

# Full LLVM build is large; for now, just install compiler-rt/libc++/libunwind
# that were cross-compiled in Phase 1 into the final sysroot location.
# This script becomes relevant after chroot to rebuild LLVM natively.

echo "=== LLVM runtime libraries already installed via toolchain ==="
echo "To rebuild LLVM natively inside chroot, run:"
echo "  cmake /path/to/llvm-project -G Ninja -DCMAKE_BUILD_TYPE=Release ..."
