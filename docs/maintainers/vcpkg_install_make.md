# vcpkg_install_make

The latest version of this document lives in the [vcpkg repo](https://github.com/Microsoft/vcpkg/blob/master/docs/maintainers/vcpkg_install_make.md).

Build and install a make project.

## Usage:
```cmake
vcpkg_install_make(...)
```

## Parameters:
See [`vcpkg_build_make()`](vcpkg_build_make.md).

## Notes:
This command transparently forwards to [`vcpkg_build_make()`](vcpkg_build_make.md), adding `ENABLE_INSTALL`

## Examples

* [x264](https://github.com/Microsoft/vcpkg/blob/master/ports/x264/portfile.cmake)
* [tcl](https://github.com/Microsoft/vcpkg/blob/master/ports/tcl/portfile.cmake)
* [freexl](https://github.com/Microsoft/vcpkg/blob/master/ports/freexl/portfile.cmake)
* [libosip2](https://github.com/Microsoft/vcpkg/blob/master/ports/libosip2/portfile.cmake)

## Source
[scripts/cmake/vcpkg\_install\_make.cmake](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/vcpkg_install_make.cmake)
