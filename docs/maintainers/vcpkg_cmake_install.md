# vcpkg_cmake_install

**The latest version of this document lives in the [vcpkg repo](https://github.com/Microsoft/vcpkg/blob/master/docs/maintainers/vcpkg_cmake_install.md).**

Build and install a cmake project.

## Usage

```cmake
vcpkg_cmake_install(
    [DISABLE_PARALLEL]
    [ADD_BIN_TO_PATH]
)
```

To use this function, you must depend on the helper port [`vcpkg-cmake`](ports/vcpkg-cmake.md):
```no-highlight
"dependencies": [
  {
    "name": "vcpkg-cmake",
    "host": true
  }
]
```

## Parameters

### DISABLE_PARALLEL
Disables running the build in parallel.

By default builds are run with up to [VCPKG_MAX_CONCURRENCY](../users/config-environment.md#VCPKG_MAX_CONCURRENCY) jobs. This option limits the build to a single job and should be used only if the underlying build is unable to run correctly with concurrency.

### ADD_BIN_TO_PATH
Adds the configuration-specific `bin/` directory to the `PATH` during the build.

When building for a Windows dynamic triplet, newly built executables may not be immediately executable because their dependency DLLs may not be findable from the build environment. This flag instructs vcpkg to add any additional paths needed to locate those dependency DLLs to the `PATH` environment variable. This is required if the project needs to execute newly built binaries as part of the build (such as to generate code).

## Examples:

```cmake
vcpkg_from_github(OUT_SOURCE_PATH source_path ...)
vcpkg_cmake_configure(SOURCE_PATH "${source_path}")
vcpkg_cmake_install()
```

[Search microsoft/vcpkg for Examples](https://github.com/microsoft/vcpkg/search?q=vcpkg_cmake_install+path%3A%2Fports)

## Remarks

This command replaces [`vcpkg_install_cmake()`](vcpkg_install_cmake.md).

## Source
[ports/vcpkg-cmake/vcpkg\_cmake\_install.cmake](https://github.com/Microsoft/vcpkg/blob/master/ports/vcpkg-cmake/vcpkg_cmake_install.cmake)
