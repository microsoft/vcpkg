# vcpkg_cmake_configure

The latest version of this document lives in the [vcpkg repo](https://github.com/Microsoft/vcpkg/blob/master/docs/maintainers/ports/vcpkg-cmake/vcpkg_cmake_configure.md).

Configure a CMake buildsystem.

```cmake
vcpkg_cmake_configure(
    SOURCE_PATH <source-path>
    [LOGFILE_BASE <logname-base>]
    [DISABLE_PARALLEL_CONFIGURE]
    [NO_CHARSET_FLAG]
    [WINDOWS_USE_MSBUILD]
    [GENERATOR <generator>]
    [OPTIONS
        <configure-setting>...]
    [OPTIONS_RELEASE
        <configure-setting>...]
    [OPTIONS_DEBUG
        <configure-setting>...]
    [MAYBE_UNUSED_VARIABLES
        <variable-name>...]
)
```

`vcpkg_cmake_configure` configures a CMake build system for use with
`vcpkg_cmake_buildsystem_build` and `vcpkg_cmake_buildsystem_install`.
`source-path` is where the source is located; by convention,
this is usually `${SOURCE_PATH}`, which is set by one of the `vcpkg_from_*` functions.
This function configures the build system for both Debug and Release builds by default,
assuming that `VCPKG_BUILD_TYPE` is not set; if it is, then it will only configure for
that build type.

Use the `OPTIONS` argument to set the configure settings for both release and debug,
and use `OPTIONS_RELEASE` and `OPTIONS_DEBUG` to set the configure settings for
release only and debug only respectively.

By default, when possible, `vcpkg_cmake_configure` uses [ninja-build]
as its build system. If the `WINDOWS_USE_MSBUILD` argument is passed, then
`vcpkg_cmake_configure` will use a Visual Studio generator on Windows;
on every other platform, `vcpkg_cmake_configure` just uses Ninja.

[ninja-build]: https://ninja-build.org/

Additionally, one may pass the specific generator a port should use with `GENERATOR`.
This is useful if some project-specific buildsystem
has been wrapped in a CMake build system that doesn't perform an actual build.
If used for this purpose, it should be set to `"NMake Makefiles"`.
`vcpkg_cmake_buildsystem_build` and `install` do not support this being set to anything
except for NMake.

For libraries which cannot be configured in parallel,
pass the `DISABLE_PARALLEL_CONFIGURE` flag. This is needed, for example,
if the library's build system writes back into the source directory during configure.
This also disables the `CMAKE_DISABLE_SOURCE_CHANGES` option.

By default, this function adds flags to `CMAKE_C_FLAGS` and `CMAKE_CXX_FLAGS`
which set the default character set to utf-8 for MSVC.
If the library sets its own code page, pass the `NO_CHARSET_FLAG` option.

This function makes certain that all options passed in are used by the
underlying CMake build system. If there are options that might be unused,
perhaps on certain platforms, pass those variable names to
`MAYBE_UNUSED_VARIABLES`.

`LOGFILE_BASE` is used to set the base of the logfile names;
by default, this is `config`, and thus the logfiles end up being something like
`config-x86-windows-dbg.log`. You can set it to anything you like;
if you set it to `config-the-first`,
you'll get something like `config-the-first-x86-windows.dbg.log`.

## Notes
This command supplies many common arguments to CMake. To see the full list, examine the source.

## Examples

* [zlib](https://github.com/Microsoft/vcpkg/blob/master/ports/zlib/portfile.cmake)
* [cpprestsdk](https://github.com/Microsoft/vcpkg/blob/master/ports/cpprestsdk/portfile.cmake)
* [poco](https://github.com/Microsoft/vcpkg/blob/master/ports/poco/portfile.cmake)
* [opencv](https://github.com/Microsoft/vcpkg/blob/master/ports/opencv/portfile.cmake)

## Source
[ports/vcpkg-cmake/vcpkg\_cmake\_configure.cmake](https://github.com/Microsoft/vcpkg/blob/master/ports/vcpkg-cmake/vcpkg_cmake_configure.cmake)
