# Packaging System

Aether uses a CMake-based package definition system.

## Defining a Package

Create a file in `packages/<category>/`:

```cmake
include("../cmake/PackageHelpers.cmake")

define_package(
    NAME        mypackage
    VERSION     1.0
    URL         https://example.com/mypackage-1.0.tar.gz
    STAGE       extra
    DEPENDS     libfoo libbar
)
```

## Build Scripts

Each package has a corresponding shell script in:
- `lfs/toolchain/` — cross-compiler packages
- `lfs/temporary/` — temporary system packages
- `lfs/base/` — base system packages

## Future

The package definitions will be used by a native C++ package manager
(currently in design) that reads the CMake metadata and handles
dependency resolution, parallel builds, and binary caching.
