# vcpkg_cmake_install

The latest version of this document lives in the [vcpkg repo](https://github.com/Microsoft/vcpkg/blob/master/docs/maintainers/ports/vcpkg-cmake/vcpkg_cmake_install.md).

Build and install a cmake project.

```cmake
vcpkg_cmake_install(
    [DISABLE_PARALLEL]
    [ADD_BIN_TO_PATH]
)
```

`vcpkg_cmake_install` transparently forwards to [`vcpkg_cmake_build()`],
with additional parameters to set the `TARGET` to `install`,
and to set the `LOGFILE_ROOT` to `install` as well.

[`vcpkg_cmake_build()`]: vcpkg_cmake_build.md

## Examples:

* [zlib](https://github.com/Microsoft/vcpkg/blob/master/ports/zlib/portfile.cmake)

## Source
[ports/vcpkg-cmake/vcpkg\_cmake\_install.cmake](https://github.com/Microsoft/vcpkg/blob/master/ports/vcpkg-cmake/vcpkg_cmake_install.cmake)
