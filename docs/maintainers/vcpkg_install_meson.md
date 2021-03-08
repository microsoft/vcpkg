# vcpkg_install_meson

The latest version of this document lives in the [vcpkg repo](https://github.com/Microsoft/vcpkg/blob/master/maintainers/vcpkg_install_meson.md).

Builds a meson project previously configured with `vcpkg_configure_meson()`.

## Usage
```cmake
vcpkg_install_meson()
```

## Examples

* [fribidi](https://github.com/Microsoft/vcpkg/blob/master/ports/fribidi/portfile.cmake)
* [libepoxy](https://github.com/Microsoft/vcpkg/blob/master/ports/libepoxy/portfile.cmake)

## Source
[scripts/cmake/vcpkg\_install\_meson.cmake](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/vcpkg_install_meson.cmake)
