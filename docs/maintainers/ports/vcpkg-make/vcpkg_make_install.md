# vcpkg_install_make

The latest version of this document lives in the [vcpkg repo](https://github.com/Microsoft/vcpkg/blob/master/docs/maintainers/ports/vcpkg-make/vcpkg_make_install.md).

Build and install a make project.

```cmake
vcpkg_make_install(
    [DISABLE_PARALLEL]
    [ADD_BIN_TO_PATH]
)
```

`vcpkg_make_install` transparently forwards to [`vcpkg_make_build()`],
with additional parameters to set `ENABLE_INSTALL`,
and to set the `LOGFILE_BASE` to `install` as well.

[`vcpkg_make_build()`]: vcpkg_make_build.cmake

## Examples

* [x264](https://github.com/Microsoft/vcpkg/blob/master/ports/x264/portfile.cmake)

## Source
[ports/vcpkg-make/vcpkg\_make\_install.cmake](https://github.com/Microsoft/vcpkg/blob/master/ports/vcpkg-make/vcpkg_make_install.cmake)
