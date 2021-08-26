#[===[.md:
# vcpkg_install_make

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
#]===]

if(Z_VCPKG_MAKE_INSTALL_GUARD)
    return()
endif()
set(Z_VCPKG_MAKE_INSTALL_GUARD ON CACHE INTERNAL "guard variable")

function(vcpkg_make_install)
    vcpkg_make_build(
        ${ARGN}
        LOGFILE_BASE install
        ENABLE_INSTALL
    )
endfunction()
