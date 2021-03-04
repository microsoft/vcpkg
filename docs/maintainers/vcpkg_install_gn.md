# vcpkg_install_gn

The latest version of this document lives in the [vcpkg repo](https://github.com/Microsoft/vcpkg/blob/master/maintainers/vcpkg_install_gn.md).

Installs a GN project

## Usage:
```cmake
vcpkg_install_gn(
     SOURCE_PATH <SOURCE_PATH>
     [TARGETS <target>...]
)
```

## Parameters:
### SOURCE_PATH
The path to the source directory

### TARGETS
Only install the specified targets.

Note: includes must be handled separately

## Source
[scripts/cmake/vcpkg\_install\_gn.cmake](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/vcpkg_install_gn.cmake)
