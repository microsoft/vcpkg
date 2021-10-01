# vcpkg_build_ninja

The latest version of this document lives in the [vcpkg repo](https://github.com/Microsoft/vcpkg/blob/master/docs/maintainers/vcpkg_build_ninja.md).

Build a ninja project

## Usage:
```cmake
vcpkg_build_ninja(
    [TARGETS <target>...]
)
```

## Parameters:
### TARGETS
Only build the specified targets.

## Source
[scripts/cmake/vcpkg\_build\_ninja.cmake](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/vcpkg_build_ninja.cmake)
