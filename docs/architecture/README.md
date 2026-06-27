# Aether Linux Architecture

Layer-by-layer design documents. Each layer is one section of the OS stack.

| Layer | Title | Status |
|-------|-------|--------|
| 1 | [Below the Kernel](layer-1-boot.md) | Draft — decisions made, stubs created |
| 2 | [Kernel](layer-2-kernel.md) | Draft — config fragments, build pipeline, firmware manifest created |
| 3 | [Init System](layer-3-init.md) | Draft — systemd now, aether-init future, IWD+networkd |
| 4 | [System Libraries & Toolchain](layer-4-libraries-toolchain.md) | Draft — llvm-libc primary, glibc-free bootstrap, libc++ exclusive |
| 5 | Package Manager | Not yet designed |
