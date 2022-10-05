# vcpkg_gn_install

The latest version of this document lives in the [vcpkg repo](https://github.com/Microsoft/vcpkg/blob/master/docs/maintainers/ports/vcpkg-gn/vcpkg_gn_install.md).

Installs a GN project.

In order to build a GN project without installing, use [`vcpkg_build_ninja()`].

## Usage:
```cmake
vcpkg_gn_install(
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

[`vcpkg_build_ninja()`]: vcpkg_build_ninja.md

## Source
[ports/vcpkg-gn/vcpkg\_gn\_install.cmake](https://github.com/Microsoft/vcpkg/blob/master/ports/vcpkg-gn/vcpkg_gn_install.cmake)
