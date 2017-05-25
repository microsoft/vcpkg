# vcpkg_install_cmake

Build and install a cmake project.

## Usage:
```cmake
vcpkg_install_cmake([MSVC_64_TOOLSET])
```

## Parameters:
### MSVC_64_TOOLSET
This adds the `/p:PreferredToolArchitecture=x64` switch if the underlying buildsystem is MSBuild. Some large projects can run out of memory when linking if they use the 32-bit hosted tools.

## Notes:
This command should be preceeded by a call to [`vcpkg_configure_cmake()`](vcpkg_configure_cmake.md).

## Examples:

* [zlib](https://github.com/Microsoft/vcpkg/blob/master/ports/zlib/portfile.cmake)
* [cpprestsdk](https://github.com/Microsoft/vcpkg/blob/master/ports/cpprestsdk/portfile.cmake)
* [poco](https://github.com/Microsoft/vcpkg/blob/master/ports/poco/portfile.cmake)
* [opencv](https://github.com/Microsoft/vcpkg/blob/master/ports/opencv/portfile.cmake)

## Source
[scripts/cmake/vcpkg_install_cmake.cmake](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/vcpkg_install_cmake.cmake)
