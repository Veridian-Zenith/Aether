# Layer 1: Below the Kernel

## Boot Architecture

### Current = systemd-boot + UKI
### Future = rEFInd + custom tool

---

## Boot Flow

```
Firmware (UEFI)
    │
    ├─ UEFI Boot Manager → systemd-boot
    │     │
    │     ├─ Detects /EFI/BOOT/BOOTX64.EFI (fallback)
    │     └─ Reads /loader/entries/*.conf → presents menu
    │
    ├─ User selects "Aether Linux"
    │     │
    │     └─ systemd-boot loads: /EFI/Linux/aether-6.14.efi
    │           │
    │           └─ This is a UKI (Unified Kernel Image):
    │                 [stub] → [kernel] → [initramfs] → [cmdline]
    │                                           │
    │                                           └─ Kernel boots, initramfs loads
    │                                                 │
    │                                                 └─ PID 1 starts (systemd)
```

---

## Components

### 1. Boot Manager: systemd-boot

- Installed to EFI System Partition (ESP) at `/EFI/systemd/systemd-bootx64.efi`
- Default loader entry set via `loader.conf`
- Currently using systemd-boot for simplicity; minimal, well-tested

#### Configuration:

```
/EFI/
├── loader/
│   ├── loader.conf          ← default entry, timeout
│   └── entries/
│       ├── aether.conf      ← current Aether entry
│       └── fallback.conf    ← recovery entry
└── Linux/
    └── aether-<ver>.efi     ← UKI files
```

##### loader.conf

```
default  aether
timeout  5
console-mode max
editor   yes
```

##### entries/aether.conf

```
title   Aether Linux
efi     /EFI/Linux/aether-6.14.efi
```

---

### 2. UKI (Unified Kernel Image)

Single EFI executable containing:

| Component | Source | Notes |
|-----------|--------|-------|
| **EFI stub** | Linux kernel (`drivers/firmware/efi/libstub`) | Handles UEFI→kernel transition |
| **Kernel** | `arch/x86_64/boot/bzImage` | Stripped, compressed |
| **Initramfs** | Custom Aether initramfs | LZ4/ZSTD compressed |
| **Cmdline** | `/proc/cmdline` | Embedded in UKI, can be overridden at boot |

#### UKI Generation

```
objcopy \
    --add-section .linux=vmlinuz    \
    --add-section .initrd=initramfs \
    --add-section .cmdline=cmdline  \
    --change-section-vma .linux=0x2000000 \
    --change-section-vma .initrd=0x3000000 \
    /usr/lib/systemd/boot/efi/linuxx64.efi.stub \
    aether-6.14.efi
```

#### Customization Before UKI Build

Users can override before `objcopy`:

- **Kernel config**: `config/kernel/kernel.config` — run `make menuconfig` before kernel build
- **Initramfs content**: Custom hooks in `/etc/initramfs-tools/hooks/` (or mkinitcpio install hooks)
- **Kernel cmdline**: Edit `config/cmdline/default.conf` before UKI generation
- **UKI stub**: Replace `/usr/lib/systemd/boot/efi/linuxx64.efi.stub` with custom build

All overrides survive `apm update` — they're in `/etc/aether/` not `/usr/`.

---

### 3. Initramfs: mkinitcpio (fork target)

Currently mkinitcpio. Future fork: custom C++ tool.

#### Required mkinitcpio hooks for Aether:

| Hook | Purpose |
|------|---------|
| `base` | Minimal rootfs skeleton |
| `udev` | Device detection |
| `autodetect` | Only include loaded modules |
| `modconf` | Module config files |
| `kms` | Kernel modesetting (i915/xe) |
| `keyboard` | LUKS password input |
| `consolefont` | Font for early boot |
| `block` | Block device drivers |
| `filesystems` | ext4, btrfs, vfat |
| `fsck` | Filesystem check |

#### Initramfs should also handle:
- LUKS decryption (if encrypted root)
- ZSTD compressed (fast decompression on i3-1215U)
- Minimal binary set (busybox stripped, or better: custom minimal init)

---

### 4. EFI Stub — Default Encapsulation

The default build produces a single `.efi` file:

```
aether-<kernel-ver>.efi  ← bootable UEFI application
```

This file contains everything needed to boot. systemd-boot presents it as a menu entry.

**Default kernel cmdline embedded in UKI:**

```
root=<UUID> rw quiet splash transparent_hugepage=madvise
split_lock_detect=off iommu=pt intel_iommu=on
intel_pstate=active,hwp_only preempt=voluntary
```

Read from `config/cmdline/default.conf` at build time. Can override at boot via systemd-boot's `editor yes`.

#### Multiple UKI variants

```
aether-6.14.efi              ← production
aether-6.14-debug.efi     ← debug (no quiet, serial, initcall_debug)
aether-6.14-fallback.efi  ← fallback (minimal initramfs, all modules)
```

Defined by profiles in `config/uki/`:

```
config/uki/
├── default.conf          ← production profile
├── debug.conf            ← debug profile
└── fallback.conf         ← fallback profile
```

Each profile can override kernel config fragments, initramfs hooks, and cmdline.

---

## Phase 1 Implementation Steps

| # | Step | Output |
|---|------|--------|
| 1 | Write UKI builder script (C++? shell prototype?) | `scripts/build-uki` |
| 2 | Define UKI profiles | `config/uki/*.conf` |
| 3 | Configure systemd-boot | `config/loader/` |
| 4 | Write initramfs hook for Aether | `config/mkinitcpio/` |
| 5 | Generate first UKI from kernel build | `rootfs/target/EFI/Linux/aether.efi` |

---

## Future: rEFInd with Custom Tool

rEFInd provides:
- Automatic EFI binary scanning
- Rich UI (icons, backgrounds)
- Scriptable with custom tools

Custom tool (C++): `aether-bootconf`
- Manages boot entries across kernels
- Handles UKI signing (Secure Boot)
- Generates rEFInd config
- Garbage-collects old kernels

Not designed yet — defer until after first boot.
