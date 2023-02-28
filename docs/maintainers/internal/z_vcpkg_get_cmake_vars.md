# z_vcpkg_get_cmake_vars

The latest version of this document lives in the [vcpkg repo](https://github.com/Microsoft/vcpkg/blob/master/docs/).

**Only for internal use in vcpkg helpers. Behavior and arguments will change without notice.**
Runs a cmake configure with a dummy project to extract certain cmake variables

## Usage
```cmake
z_vcpkg_get_cmake_vars(<out-var>)
```

`z_vcpkg_get_cmake_vars(cmake_vars_file)` sets `<out-var>` to
a path to a generated CMake file, with the detected `CMAKE_*` variables
re-exported as `VCPKG_DETECTED_*`.

## Notes
Avoid usage in portfiles. 

All calls to `z_vcpkg_get_cmake_vars` will result in the same output file;
the output file is not generated multiple times.

## Examples

* [vcpkg_configure_make](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/vcpkg_configure_make.cmake)

### Basic Usage

```cmake
z_vcpkg_get_cmake_vars(cmake_vars_file)
include("${cmake_vars_file}")
message(STATUS "detected CXX flags: ${VCPKG_DETECTED_CXX_FLAGS}")
```

## Source
[scripts/cmake/z\_vcpkg\_get\_cmake\_vars.cmake](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/z_vcpkg_get_cmake_vars.cmake)
