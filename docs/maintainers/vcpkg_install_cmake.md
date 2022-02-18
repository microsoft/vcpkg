# vcpkg_install_cmake

**This function has been deprecated in favor of [`vcpkg_cmake_install`](ports/vcpkg-cmake/vcpkg_cmake_install.md) from the vcpkg-cmake port.**

The latest version of this document lives in the [vcpkg repo](https://github.com/Microsoft/vcpkg/blob/master/docs/maintainers/vcpkg_install_cmake.md).

Build and install a cmake project.

## Usage:
```cmake
vcpkg_install_cmake(...)
```

## Parameters:
See [`vcpkg_build_cmake()`](vcpkg_build_cmake.md).

## Notes:
This command transparently forwards to [`vcpkg_build_cmake()`](vcpkg_build_cmake.md), adding a `TARGET install`
parameter.

## Examples:

* [zlib](https://github.com/Microsoft/vcpkg/blob/master/ports/zlib/portfile.cmake)
* [cpprestsdk](https://github.com/Microsoft/vcpkg/blob/master/ports/cpprestsdk/portfile.cmake)
* [poco](https://github.com/Microsoft/vcpkg/blob/master/ports/poco/portfile.cmake)
* [opencv](https://github.com/Microsoft/vcpkg/blob/master/ports/opencv/portfile.cmake)

## Source
[scripts/cmake/vcpkg\_install\_cmake.cmake](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/vcpkg_install_cmake.cmake)
