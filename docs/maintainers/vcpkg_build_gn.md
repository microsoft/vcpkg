# vcpkg_build_gn

The latest version of this document lives in the [vcpkg repo](https://github.com/Microsoft/vcpkg/blob/master/maintainers/vcpkg_build_gn.md).

Build a GN project

## Usage:
```cmake
vcpkg_build_gn(
    [TARGETS <target>...]
)
```

## Parameters:
### TARGETS
Only build the specified targets.

## Source
[scripts/cmake/vcpkg\_build\_gn.cmake](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/vcpkg_build_gn.cmake)
