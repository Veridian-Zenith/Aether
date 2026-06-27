# Layer 5: Package Manager

**Name**: `apm` (Aether Package Manager)

---

## Design Tenets

| Tenet | Why |
|-------|-----|
| **Binary by default** | `apm add` installs pre-compiled `.aet` packages from repos |
| **Source builds available** | `apm add-src` builds from source using CMake recipes |
| **Everything is a package** | Kernel, toolchain, drivers, firmware — all managed by apm |
| **C++ implementation** | Single binary, no shell scripts, no Python |
| **Signed packages** | Ed25519 signatures for both binary packages and repo metadata |
| **No circular deps** | Dependency graph must be a DAG; enforced at repo level |
| **Deterministic builds** | Source recipes pin exact sources and build flags |

---

## Commands

| Command | Action |
|---------|--------|
| `apm add <pkg>` | Install binary package + dependencies |
| `apm add-src <pkg>` | Build from source recipe + install |
| `apm del <pkg>` | Remove package (with dep checks) |
| `apm upd` | Update all installed packages to latest |
| `apm search <query>` | Search remote repos |
| `apm info <pkg>` | Show details from repo metadata |
| `apm info-local <pkg>` | Show details from local database |
| `apm list` | List installed packages |
| `apm check` | Verify installed package integrity |
| `apm repo add <name> <url>` | Add a repository |
| `apm repo remove <name>` | Remove a repository |
| `apm clean` | Clear cached packages |

---

## Package Format (`.aet`)

Aether binary packages are ZSTD-compressed archives with an embedded manifest.

```
pkgname-1.0.0-x86_64.aet
├── manifest.json           ← Required. Package metadata.
├── root/                   ← Files extracted to /
│   ├── usr/bin/foo
│   ├── usr/lib/libfoo.so
│   └── usr/share/...
└── install                 ← Optional. Post-install script (executable)

manifest.json structure:
{
  "name": "foo",
  "version": "1.0.0",
  "arch": "x86_64_v3",
  "license": "MIT",
  "summary": "Example package",
  "deps": ["bar >= 2.0", "baz"],
  "makedeps": ["cmake >= 3.18", "clang"],
  "sha256sum": "abc123...",            // of the root/ contents
  "size": {"installed": 123456, "packaged": 12345},
  "provides": ["libfoo.so=1.0"],
  "conflicts": ["oldfoo"],
  "signature": "base64(ed25519_sign(manifest))"
}
```

### Binary layer:
- Payload is a ZSTD-compressed tar archive of `root/`
- Fast decompression, small on disk
- `install` script if present is extracted next to root/

### Install location:
- Extracted directly into `/` (sysroot-aware: can target `DESTDIR` / `--root`)
- File ownership: `root:root` by default, overrideable in manifest
- Permission bits preserved from the archive

---

## Package Database (Local)

Stored at `/var/lib/apm/`:

```
/var/lib/apm/
├── db.json                 ← Master index of installed packages
├── files/                  ← File manifests per package
│   ├── foo.json            ← list of files owned by foo
│   └── bar.json
── cache/                    ← Downloaded .aet files
│   └── foo-1.0.0-x86_64.aet
── sources/                  ← Downloaded source archives (for add-src)
│   └── foo/
│       └── foo-1.0.0.tar.gz
-- builds/                   ← Build directories (add-src temporary)
-- config/
    ├── apm.conf             ← Global config (repo list, settings)
    ├── repos.conf.d/        ← Repo definitions (one per file)
    └── keyring/             ← Trusted signing keys
```

### db.json format:
```json
{
  "packages": {
    "foo": {
      "version": "1.0.0",
      "arch": "x86_64_v3",
      "repo": "aether-core",
      "files": "files/foo.json",
      "manifest": { ... }
    }
  },
  "pkgname-version": {
    "foo-1.0.0": {
      "files": ["usr/bin/foo", "usr/lib/libfoo.so", ...],
      "manifest": { ... },
      "install_script": true,
      "checksum": "sha256..."
    }
  }
}
```

---

## Repository Structure

Remote repos are served as static files over HTTP/S:

```
https://packages.aetherlinux.org/
├── repo.json                ← Signed index of all packages in repo
├── repo.json.sig            ← Ed25519 signature
├── packages/
│   ├── foo-1.0.0-x86_64.aet
│   ├── foo-1.1.0-x86_64.aet
│   └── bar-2.0.0-x86_64.aet
── recipes/                   ← Source build recipes (for add-src)
│   ├── foo/
│   │   ├── recipe.json      ← Build recipe metadata
│   │   └── sources/         ← Cached source tarballs (optional)
│   └── bar/
── keys/
    └── repo-key.pub          ← Repo's public key for verification
```

### repo.json (signed):
```json
{
  "repo": "aether-core",
  "version": 1,
  "arch": "x86_64_v3",
  "packages": {
    "foo": {
      "versions": {
        "1.0.0": {
          "filename": "foo-1.0.0-x86_64.aet",
          "sha256": "abc...",
          "deps": ["bar>=2.0"],
          "size": 12345
        }
      }
    }
  },
  "signed_by": "keyid@aetherlinux.org",
  "timestamp": "..."
}
```

The repo index is small and fetched once per `apm upd`. Package `.aet` files are fetched on demand for `add`.

---

## Dependency Resolution

### Algorithm: Simple topological sort (no SAT solver needed)

1. Collect required packages from `apm add` + their transitive deps
2. Walk the dep graph, detect cycles → error
3. Sort topologically
4. Check for version conflicts (`conflicts` field)
5. Check for providers (`provides` field resolves virtual packages)
6. Download and install in order

### Version comparison:
- Semantic versioning (`MAJOR.MINOR.PATCH`)
- Pre-release tags (`-alpha`, `-beta`, `-rc1`)
- Comparison operators: `>=`, `<=`, `>`, `<`, `=`, `~>` (pessimistic)

---

## Source Builds (`apm add-src`)

### Build recipe is a CMake project:

```
recipes/foo/
├── recipe.json              ← Package metadata (name, version, deps, etc.)
├── CMakeLists.txt           ← Build instructions
└── patches/                 ← Optional patches
```

### recipe.json:
```json
{
  "name": "foo",
  "version": "1.0.0",
  "source": "https://example.com/foo-1.0.0.tar.gz",
  "sha256": "abc...",
  "deps": ["bar >= 2.0"],
  "makedeps": ["cmake", "clang"],
  "build_system": "cmake",
  "options": ["-DBUILD_SHARED_LIBS=ON"]
}
```

### Build process:
1. Download source tarball → verify checksum
2. Extract to `/var/lib/apm/sources/foo/`
3. Apply patches from `recipes/foo/patches/`
4. Run CMake configure + build in a separate build directory
5. `DESTDIR=/var/lib/apm/builds/foo/ make install`
6. Package the installed files into a `.aet`
7. Install the `.aet` via normal path (file manifest, db update)

### Sandboxing:
- Builds run in a temporary directory
- No network access during build (source fetched beforehand)
- `MAKEFLAGS` respected for parallelism
- Build directory cleaned after successful install

---

## Repo Types

| Type | Purpose | Example |
|------|---------|---------|
| `aether-core` | Base system packages | glibc-stage1, kernel, llvm, fish, iwd |
| `aether-extra` | Additional maintained packages | ripgrep, fd, eza, bat |
| `aether-contrib` | Community-maintained packages | (future) |
| `local` | Locally built packages | `apm add-src` outputs go here |

Configurable in `/etc/apm/repos.conf.d/`:

```
[aether-core]
url = https://packages.aetherlinux.org/core
signing-key = /etc/apm/keyring/aether-core.pub

[aether-extra]
url = https://packages.aetherlinux.org/extra
signing-key = /etc/apm/keyring/aether-extra.pub
```

---

## Config File: `/etc/apm/apm.conf`

```toml
[general]
root = "/"                        # Install root (for chroot builds)
arch = "x86_64_v3"
parallel = 8                      # Parallel downloads/builds
cache-dir = "/var/lib/apm/cache"
keep-cache = true

[build]
build-dir = "/var/lib/apm/builds"
source-dir = "/var/lib/apm/sources"
sandbox = false                   # Future: bubblewrap/namespaces
keep-build = false

[verify]
signature = true                  # Verify repo/package signatures
keyring = "/etc/apm/keyring"

[keyring]
auto-import = false               # Must manually trust keys
```

---

## Phase 5 Implementation Steps

| # | Step | Output |
|---|------|--------|
| 1 | Design `.aet` file format in detail | Format spec (partially done here) |
| 2 | Write `.aet` read/write library (C++) | `libapm-format` |
| 3 | Write local database (install/remove/query) | `libapm-db` |
| 4 | Write repo metadata fetch + verify | `libapm-repo` |
| 5 | Write dependency resolver | `libapm-deps` |
| 6 | Write `apm add` (binary install) | First working command |
| 7 | Write `apm del` | Second command |
| 8 | Write `apm upd` | Third command |
| 9 | Write `apm search`, `apm info`, `apm info-local` | Query commands |
| 10 | Write `apm add-src` (source build) | Full pipeline |
| 11 | Write `apm repo add/remove` | Repo management |
| 12 | Integrate into bootstrap: apm installs itself | Self-hosting package manager |

---

## Integration with Build Pipeline

The package manager is *not* used for the initial bootstrap (LFS phases 1-3). Instead:

```
LFS bootstrap (shell + CMake)  →  produces first system with apm
                                         │
                                    apm installs itself
                                         │
                                    apm builds and installs everything else
                                         │
                                    glibc removed, llvm-libc takes over
                                         │
                                    LFS scripts retired
```

After the bootstrap, all updates and new packages go through `apm`. The LFS build scripts are replaced by `apm add-src` with CMake recipes.
