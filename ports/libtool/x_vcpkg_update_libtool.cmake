#[===[.md:
# x_vcpkg_update_libtool

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

## Examples

* [gettext](https://github.com/microsoft/vcpkg/blob/master/ports/gettext/portfile.cmake)
* [libiconv](https://github.com/microsoft/vcpkg/blob/master/ports/libiconv/portfile.cmake)
#]===]
if(Z_VCPKG_UPDATE_LIBTOOL_GUARD)
    return()
endif()
set(Z_VCPKG_UPDATE_LIBTOOL_GUARD ON CACHE INTERNAL "guard variable")

function(x_vcpkg_update_libtool)
    cmake_parse_arguments(PARSE_ARGV 0 arg
        "RECURSE"
        "SOURCE_PATH"
        ""
    )
    if(NOT DEFINED arg_SOURCE_PATH OR arg_SOURCE_PATH STREQUAL "")
        message(FATAL_ERROR "x_vcpkg_update_libtool requires parameter SOURCE_PATH!")
    endif()

    if(arg_RECURSE)
        file(GLOB_RECURSE files "${arg_SOURCE_PATH}/ltmain.sh")
    else()
        set(files "${arg_SOURCE_PATH}/build-aux/ltmain.sh")
    endif()
    foreach(file IN LISTS files)
        configure_file("${CURRENT_HOST_INSTALLED_DIR}/share/@PORT@/libtool/build-aux/ltmain.sh" "${file}" COPYONLY)
    endforeach()
endfunction()
