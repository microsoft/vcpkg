# vcpkg_install_gn

Installs a GN project

## Usage:
```cmake
vcpkg_install_gn(
     SOURCE_PATH <SOURCE_PATH>
     [PATH_SUFFIX <PATH_SUFFIX>]
     [TARGETS <target>...]
)
```

## Parameters:
### SOURCE_PATH
The path to the source directory

### PATH_SUFFIX
Subdirectory suffix to be added to the bin, lib and tool directories.

### TARGETS
Only install the specified targets.

Note: includes must be handled separately

## Source
[scripts/cmake/vcpkg_install_gn.cmake](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/vcpkg_install_gn.cmake)
