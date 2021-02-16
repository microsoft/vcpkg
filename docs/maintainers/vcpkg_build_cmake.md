# vcpkg_build_cmake

Build a cmake project.

## Usage:
```cmake
vcpkg_build_cmake([DISABLE_PARALLEL] [TARGET <target>])
```

## Parameters:
### DISABLE_PARALLEL
The underlying buildsystem will be instructed to not parallelize

### TARGET
The target passed to the cmake build command (`cmake --build . --target <target>`). If not specified, no target will
be passed.

### ADD_BIN_TO_PATH
Adds the appropriate Release and Debug `bin\` directories to the path during the build such that executables can run against the in-tree DLLs.

## Notes:
This command should be preceeded by a call to [`vcpkg_configure_cmake()`](vcpkg_configure_cmake.md).
You can use the alias [`vcpkg_install_cmake()`](vcpkg_configure_cmake.md) function if your CMake script supports the
"install" target

## Examples:

* [zlib](https://github.com/Microsoft/vcpkg/blob/master/ports/zlib/portfile.cmake)
* [cpprestsdk](https://github.com/Microsoft/vcpkg/blob/master/ports/cpprestsdk/portfile.cmake)
* [poco](https://github.com/Microsoft/vcpkg/blob/master/ports/poco/portfile.cmake)
* [opencv](https://github.com/Microsoft/vcpkg/blob/master/ports/opencv/portfile.cmake)

## Source
[scripts/cmake/vcpkg_build_cmake.cmake](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/vcpkg_build_cmake.cmake)
