# Layer 2: The Kernel

## Core Identity

| Property | Decision |
|----------|----------|
| Version | Linux 6.14 (LTS-track, whatever is latest stable) |
| Scheduler | EEVDF + sched-ext/SCX_LAVD |
| Compiler | Clang 22+ with ThinLTO |
| Architecture | x86-64-v3 (Alder Lake native) |
| Module policy | Modular by default; tooling to merge into UKI |
| Firmware | Only required blobs for i3-1215U |
| Secure Boot | Plan now; custom tool for key management |

---

## Patch Stack

### CachyOS patches to carry:
- sched-ext (SCX) fixes and enhancements
- LTO/ThinLTO build fixes
- PCI overrides for non-standard controllers
- MultiQ scheduler enhancements
- Performance tuning defaults

### Aether-specific patches:
- Local version: `-aether`
- Default config fragments for x86-64-v3
- Custom preemption model config (voluntary)

Patches live in `base/kernel/patches/` and are applied in order via `base/kernel/fetch-cachyos-patches.sh`.

---

## Build

### Toolchain
```
CC=clang LD=ld.lld AR=llvm-ar NM=llvm-nm
OBJCOPY=llvm-objcopy OBJDUMP=llvm-objdump
STRIP=llvm-strip READELF=llvm-readelf
HOSTCC=clang HOSTCXX=clang++ HOSTLD=ld.lld
LLVM=1 LLVM_IAS=1
```

### Flags
```
-march=native -O3 -flto=thin -fno-plt
```

### Targets
```
make CC=clang LLVM=1 -j$(nproc) bzImage modules
```

---

## Module Policy

### Default: Modular
- Modules installed to `/usr/lib/modules/<ver>-aether/`
- Initramfs (mkinitcpio) autodetects needed modules via `autodetect` hook
- Only modules actually loaded by hardware are included in initramfs

### Unified (optional): `aether-merge`
A tool (C++) that:
1. Builds kernel with modules
2. Builds initramfs with mkinitramfs
3. Merges kernel + initramfs + cmdline into UKI
4. Optionally bundles select modules into initramfs

Falls back to traditional kernel + initramfs split for development.

```
aether-merge --profile default  → produces aether-6.14.efi
aether-merge --help             → list profiles
```

---

## Firmware

### Only required blobs for i3-1215U:

| Hardware | Required Firmware |
|----------|------------------|
| **GPU**: Intel Xe (Alder Lake) | `i915/`, `intel/display/`, `xe/` |
| **WiFi**: Intel AX201 | `iwlwifi-QuZ-a0-hr-b0-72.ucode` |
| **Bluetooth**: Integrated | `intel/ibt-0040-0041.sfi` |
| **NVMe**: Controller | No firmware needed (controller-based) |
| **Audio**: Intel SOF | `intel/sof/`, `intel/sof-tplg/` |
| **ME/PMC**: Management Engine | `intel/ipts/`, `intel/me/`, `intel/pmc/` |

Source: `linux-firmware` with a manifest file at `config/firmware/manifest.txt` that lists only needed files. Install script copies only matching paths.

---

## Secure Boot

### Design goals:
- Custom key enrollment (PK, KEK, db)
- UKI signing as part of `aether-merge`
- MOK (Machine Owner Key) support for dual-boot
- Key backup and recovery tools
- Inspiration: `sbctl` but more robust, written in C++, with:
  - Key generation
  - EFI variable management
  - Automatic signing on UKI rebuild
  - Verification and audit

Not implemented until after first boot but the design is:
```
aether-sb enroll           # Generate + enroll keys
aether-sb sign /path/to.efi  # Sign a binary
aether-sb verify           # Check all EFI binaries are signed
aether-sb rotate           # Generate new keys, re-sign everything
aether-sb backup           # Export keys to encrypted backup
```

---

## Config Overrides

### Kernel config is layered:

```
base/kernel/config/
├── base.config              ← Aether baseline (minimal, security-hardened)
├── alderlake.config         ← i3-1215U specific (GPU, audio, wifi)
├── cachyos.config           ← CachyOS performance tweaks
└── modules.config           ← All modules as =m, core as =y
```

`make ARCH=x86_64 LLVM=1 KCONFIG_ALLCONFIG=<dir> alldefconfig`

---

## Build Pipeline Integration

```
toolchain-base
    │
    └── base-kernel
            │
            ├── 1. apply-patches        base/kernel/patches/*.patch
            ├── 2. merge-config         base/kernel/config/*.config → .config
            ├── 3. make bzImage         CC=clang LLVM=1 ThinLTO
            ├── 4. make modules         install to /usr/lib/modules/
            ├── 5. build-initramfs      mkinitcpio -k <ver> -c aether.conf
            └── 6. aether-merge         (optional) → UKI
```

---

## Phase 2 Implementation Steps

| # | Step | Output |
|---|------|--------|
| 1 | Create kernel config fragments | `base/kernel/config/*.config` |
| 2 | Write CachyOS patch fetcher | `base/kernel/fetch-cachyos-patches.sh` (done) |
| 3 | Write UKI merge tool prototype | `scripts/aether-merge` → C++ later |
| 4 | Write firmware manifest | `config/firmware/manifest.txt` |
| 5 | First kernel build | `rootfs/target/boot/vmlinuz-6.14-aether` |
| 6 | First initramfs | `rootfs/target/boot/initramfs-6.14-aether.img` |
| 7 | First UKI | `rootfs/target/EFI/Linux/aether-6.14.efi` |
