#[===[.md:
# vcpkg_cmake_install

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
#]===]
if(Z_VCPKG_CMAKE_INSTALL_GUARD)
    return()
endif()
set(Z_VCPKG_CMAKE_INSTALL_GUARD ON CACHE INTERNAL "guard variable")

function(vcpkg_cmake_install)
    cmake_parse_arguments(PARSE_ARGV 0 "arg" "DISABLE_PARALLEL;ADD_BIN_TO_PATH" "" "")
    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "vcpkg_cmake_install was passed extra arguments: ${arg_UNPARSED_ARGUMENTS}")
    endif()

    set(args)
    foreach(arg IN ITEMS DISABLE_PARALLEL ADD_BIN_TO_PATH)
        if(arg_${arg})
            list(APPEND args "${arg}")
        endif()
    endforeach()

    vcpkg_cmake_build(
        ${args}
        LOGFILE_BASE install
        TARGET install
    )
endfunction()
