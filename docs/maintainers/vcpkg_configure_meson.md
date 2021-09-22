# vcpkg_configure_meson

The latest version of this document lives in the [vcpkg repo](https://github.com/Microsoft/vcpkg/blob/master/docs/maintainers/vcpkg_configure_meson.md).

Configure Meson for Debug and Release builds of a project.

## Usage
```cmake
vcpkg_configure_meson(
    SOURCE_PATH <${SOURCE_PATH}>
    [NO_PKG_CONFIG]
    [OPTIONS <-DUSE_THIS_IN_ALL_BUILDS=1>...]
    [OPTIONS_RELEASE <-DOPTIMIZE=1>...]
    [OPTIONS_DEBUG <-DDEBUGGABLE=1>...]
)
```

## Parameters
### SOURCE_PATH
Specifies the directory containing the `meson.build`.
By convention, this is usually set in the portfile as the variable `SOURCE_PATH`.

### OPTIONS
Additional options passed to Meson during the configuration.

### OPTIONS_RELEASE
Additional options passed to Meson during the Release configuration. These are in addition to `OPTIONS`.

### OPTIONS_DEBUG
Additional options passed to Meson during the Debug configuration. These are in addition to `OPTIONS`.

### NO_PKG_CONFIG
Disable pkg-config setup 

## Notes
This command supplies many common arguments to Meson. To see the full list, examine the source.

## Examples

* [fribidi](https://github.com/Microsoft/vcpkg/blob/master/ports/fribidi/portfile.cmake)
* [libepoxy](https://github.com/Microsoft/vcpkg/blob/master/ports/libepoxy/portfile.cmake)

## Source
[scripts/cmake/vcpkg\_configure\_meson.cmake](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/vcpkg_configure_meson.cmake)
