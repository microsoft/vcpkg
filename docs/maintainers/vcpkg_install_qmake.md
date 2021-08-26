# vcpkg_install_qmake

The latest version of this document lives in the [vcpkg repo](https://github.com/Microsoft/vcpkg/blob/master/docs/maintainers/vcpkg_install_qmake.md).

Build and install a qmake project.

## Usage:
```cmake
vcpkg_install_qmake(...)
```

## Parameters:
See [`vcpkg_build_qmake()`](vcpkg_build_qmake.md).

## Notes:
This command transparently forwards to [`vcpkg_build_qmake()`](vcpkg_build_qmake.md).

Additionally, this command will copy produced .libs/.dlls/.as/.dylibs/.sos to the appropriate
staging directories.

## Examples

* [libqglviewer](https://github.com/Microsoft/vcpkg/blob/master/ports/libqglviewer/portfile.cmake)

## Source
[scripts/cmake/vcpkg\_install\_qmake.cmake](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/vcpkg_install_qmake.cmake)
