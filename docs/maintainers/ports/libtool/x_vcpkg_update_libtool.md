# x_vcpkg_update_libtool

The latest version of this document lives in the [vcpkg repo](https://github.com/Microsoft/vcpkg/blob/master/docs/maintainers/ports/libtool/x_vcpkg_update_libtool.md).

Experimental
Directly update libtool (`ltmain.sh`) in a source directory.
This function can be called before `vcpkg_configure_make` in order to improve
build time and platform support over building with stock libtool 2.4.6.
It does not require regenerating `configure` via `autoreconf`.

## Usage
```cmake
x_vcpkg_update_libtool(
    SOURCE_PATH <${SOURCE_PATH}>
    [RECURSE]
)
```
## Parameters

### SOURCE_PATH
Specifies the directory containing the source code.
By convention, this is usually set in the portfile as the variable `SOURCE_PATH`.

### RECURSE
Instead of just updating `${SOURCE_PATH}/build-aux/ltmain.sh`, look recursively
for all files named `ltmain.sh`.

## Source
[ports/libtool/x\_vcpkg\_update\_libtool.cmake](https://github.com/Microsoft/vcpkg/blob/master/ports/libtool/x_vcpkg_update_libtool.cmake)
