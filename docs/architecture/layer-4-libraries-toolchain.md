# Layer 4: System Libraries & Toolchain

## Principles

| Principle | Rationale |
|-----------|-----------|
| **llvm-libc is primary** | First-class libc, built for clang/LLVM. No GNU legacy. Used by everything. |
| **Everything dynamic** | Every library ships as `.so` + `.a`. No hard-coded paths. Search paths configurable via `/etc/ld.so.conf` at runtime, `-rpath-link` at build time. |
| **Everything adjustable** | No baked-in assumptions about filesystem layout. Toolchain respects `--sysroot`, `--prefix`, `DESTDIR`. Any path can be overridden. |
| **libc++ exclusively** | `libstdc++` never enters the system. Not even for bootstrap. |
| **mold preferred** | lld as system default (ship-safe), mold for interactive dev builds (faster). `LD` env var selects. |
| **glibc deferred** | llvm-libc first. glibc may be forked later for specific hardware or legacy compat, but never as default. |

---

## Bootstrap Strategy: Glibc-Free

The goal is zero glibc at any stage. llvm-libc + compiler-rt provides everything needed.

### Ideal bootstrap graph:

```
linux-headers  (kernel ABI, no libc needed)
      │
      ▼
compiler-rt   (builtins only — __ashlti3, __udivmodti4, etc.)
      │         No libc dependency. Pure freestanding.
      ▼
llvm-libc     (syscall wrappers, string, stdio, TLS, signals)
      │         Depends on: linux-headers, compiler-rt builtins
      │         Built with: host clang, --nostdlib, -nolibc
      ▼
libunwind     (unwind tables, backtrace)
      │         Depends on: llvm-libc
      ▼
libc++abi     (C++ ABI, demangling, exception handling)
      │         Depends on: llvm-libc, libunwind
      ▼
libc++        (C++ standard library)
      │         Depends on: llvm-libc, libc++abi
      ▼
lld           (LLVM linker)
      │         Depends on: llvm-libc, libc++
      ▼
            ┌───────────────────────────────┐
            │  Self-hosting LLVM toolchain   │
            │  clang + lld + llvm-libc       │
            │  builds everything else         │
            └───────────────────────────────┘
```

### Bootstrap variant: Stage-1 glibc fallback

If llvm-libc is missing a feature that libunwind or libc++ needs:

```
linux-headers → glibc (stage 1) → compiler-rt → libunwind → libc++abi → libc++ → lld → llvm-libc (final)
                                                                                              │
                                                                                              ▼
                                                                              Rebuild everything → glibc deleted
```

Stage-1 glibc is temporary — built, used, then removed once llvm-libc is self-hosting.

---

## Library Layout

### Install prefix: `/usr`
### Dynamic linker: `/usr/lib/ld-linux-x86-64.so.2` (symlink to ld.lld)

```
/usr/lib/
├── libc.so                → libllvmlibc.so        (llvm-libc)
├── libm.so                → libllvmlibc.so        (llvm-libc provides math)
├── libpthread.so          → libllvmlibc.so        (llvm-libc: threads in same lib)
├── librt.so               → libllvmlibc.so
├── libdl.so               → libllvmlibc.so
├── libc++.so              → libc++.so.1             (LLVM libc++)
├── libc++abi.so           → libc++abi.so.1          (LLVM libc++abi)
├── libunwind.so           → libunwind.so.1          (LLVM libunwind)
├── libclang_rt.builtins   → ...compiler-rt builtins
├── ld.lld                 → .../lld                 (dynamic linker)
├── ld.so                  → ld.lld                  (symlink for compatibility)
├── ld-linux-x86-64.so.2   → ld.lld                  (glibc-compatible path)
└── pkgconfig/                                       (pkg-config .pc files)
```

`/etc/ld.so.conf`:
```
/usr/lib
/usr/local/lib
/opt/lib
```

No `ldconfig` needed at boot — `ld.lld` reads `LD_LIBRARY_PATH` and `-rpath`. A minimal `ldconfig` equivalent is provided for compatibility with packages that expect it.

---

## Toolchain Selection

| Tool | Default | Alternative | How to switch |
|------|---------|-------------|---------------|
| C compiler | `clang` | — | `CC=clang` (only option) |
| C++ compiler | `clang++` | — | `CXX=clang++` (only option) |
| Assembler | `clang` (integrated) | — | `AS=clang` |
| Linker | `ld.lld` | `ld.mold` | `LD=ld.mold` or `-fuse-ld=mold` |
| Archiver | `llvm-ar` | `ar` (GNU) | `AR=llvm-ar` |
| nm | `llvm-nm` | — | |
| objcopy | `llvm-objcopy` | — | |
| strip | `llvm-strip` | — | |
| ranlib | `llvm-ranlib` | — | |
| readelf | `llvm-readelf` | — | |

All `llvm-*` tools are symlinks to a single `llvm-toolchain` multi-call binary (future).

---

## Runtime Configurability

### ld.lld search path (via `/etc/ld.so.conf`):
```
include /etc/ld.so.conf.d/*.conf
/usr/lib
/usr/local/lib
```

### ld.lld behavior flags (via `/etc/ld.so.config`):
```
# /etc/ld.so.config — read by ld.lld at startup
hash-style        sysv          # gnu, both, sysv
audit             no            # enable LD_AUDIT
ignore-branch-island no         # PLT optimizations
```

### C library config (`/etc/llvm-libc.conf`):
```
# Locale
locale-path       /usr/share/locale
locale-default    C.UTF-8

# Memory
malloc            scudo         # scudo, mimalloc, jemalloc, none
mallopt           mmap-threshold=128k

# Threading
pthread           rseq          # rseq (kernel restartable sequences)
stack-size        default=8M
guard-size        default=4K
```

---

## C++ Standard Library Defaults

- libc++ linked **dynamically** by default (`-lc++`)
- Static linking available via `-static-libstdc++` (maps to `-static-libc++`)
- ABI: libc++abi (v1 ABI, `__cxxabiv1::`)
- Exception handling: libunwind (DWARF+SEH, no libgcc_s)
- `-stdlib=libc++` is the default — no `-stdlib=libstdc++` available on the system

---

## Phase 4 Implementation Steps

| # | Step | Output |
|---|------|--------|
| 1 | Write llvm-libc cross-build script | `toolchain/scripts/03-llvm-libc.sh` |
| 2 | Test that llvm-libc builds with only linux-headers | First glibc-free compile |
| 3 | If llvm-libc fails, write stage-1 glibc fallback | `toolchain/scripts/02-glibc-stage1.sh` |
| 4 | Build `ld.so` config for lld as dynamic linker | `config/ld.so.conf` |
| 5 | Build `ld.so.config` with runtime flags | `config/ld.so.config` |
| 6 | Test: compile a static hello world against llvm-libc | Proof of no-glibc toolchain |
| 7 | Test: compile a dynamic hello world running in root context | Proof of runtime linking |
