# vcpkg_cmake_get_vars

The latest version of this document lives in the [vcpkg repo](https://github.com/Microsoft/vcpkg/blob/master/docs/maintainers/ports/vcpkg-cmake/vcpkg_cmake_get_vars.md).

Runs a cmake configure with a dummy project to extract certain cmake variables

## Usage
```cmake
vcpkg_cmake_get_vars(<out-var>)
```

`vcpkg_cmake_get_vars(<out-var>)` sets `<out-var>` to
a path to a generated CMake file, with the detected `CMAKE_*` variables
re-exported as `VCPKG_DETECTED_CMAKE_*`.

## Notes
Avoid usage in portfiles.

All calls to `vcpkg_cmake_get_vars` will result in the same output file;
the output file is not generated multiple times.

### Basic Usage

```cmake
vcpkg_cmake_get_vars(cmake_vars_file)
include("${cmake_vars_file}")
message(STATUS "detected CXX flags: ${VCPKG_DETECTED_CMAKE_CXX_FLAGS}")
```

## Source
[ports/vcpkg-cmake/vcpkg\_cmake\_get\_vars.cmake](https://github.com/Microsoft/vcpkg/blob/master/ports/vcpkg-cmake/vcpkg_cmake_get_vars.cmake)
