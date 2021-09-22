# DEPRECATED BY ports/vcpkg-make/vcpkg_make_install
#[===[.md:
# vcpkg_install_make

Build and install a make project.

## Usage:
```cmake
vcpkg_install_make(...)
```

## Parameters:
See [`vcpkg_build_make()`](vcpkg_build_make.md).

## Notes:
This command transparently forwards to [`vcpkg_build_make()`](vcpkg_build_make.md), adding `ENABLE_INSTALL`

## Examples

* [x264](https://github.com/Microsoft/vcpkg/blob/master/ports/x264/portfile.cmake)
* [tcl](https://github.com/Microsoft/vcpkg/blob/master/ports/tcl/portfile.cmake)
* [freexl](https://github.com/Microsoft/vcpkg/blob/master/ports/freexl/portfile.cmake)
* [libosip2](https://github.com/Microsoft/vcpkg/blob/master/ports/libosip2/portfile.cmake)
#]===]

function(vcpkg_install_make)
    if(Z_VCPKG_MAKE_INSTALL_GUARD)
        message(FATAL_ERROR "The ${PORT} port already depends on vcpkg-make; using both vcpkg-make and vcpkg_install_make in the same port is unsupported.")
    endif()
    vcpkg_build_make(${ARGN} LOGFILE_ROOT ENABLE_INSTALL)
endfunction()
