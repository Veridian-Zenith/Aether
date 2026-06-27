# Aether Architecture

Layer-by-layer design documents. Each layer is one section of the OS stack — from silicon to package manager.

| Layer | Title | Status |
|-------|-------|--------|
| 1 | [Below the Kernel](layer-1-boot.md) | Boot flow, UKI, systemd-boot, initramfs |
| 2 | [The Kernel](layer-2-kernel.md) | EEVDF+LAVD, ThinLTO, config fragments, firmware |
| 3 | [Init System](layer-3-init.md) | systemd now, aether-init future, IWD+networkd |
| 4 | [Libraries & Toolchain](layer-4-libraries-toolchain.md) | llvm-libc primary, glibc-free bootstrap, libc++ |
| 5 | [Package Manager](layer-5-package-manager.md) | .aet format, repo structure, dep resolution, apm commands |

Each layer has config stubs and build scripts in `config/` and the respective source directories.
