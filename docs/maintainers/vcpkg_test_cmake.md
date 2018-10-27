# vcpkg_test_cmake

Tests a built package for CMake `find_package()` integration.

## Usage:
```cmake
vcpkg_test_cmake(PACKAGE_NAME <name> [MODULE])
```

## Parameters:

### PACKAGE_NAME
The expected name to find with `find_package()`.

### MODULE
Indicates that the library expects to be found via built-in CMake targets.


## Source
[scripts/cmake/vcpkg_test_cmake.cmake](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/vcpkg_test_cmake.cmake)
