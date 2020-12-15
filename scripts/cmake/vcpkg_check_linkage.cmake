#[===[.md:
# vcpkg_check_linkage

Asserts the available library and CRT linkage options for the port.

## Usage
```cmake
vcpkg_check_linkage(
    [ONLY_STATIC_LIBRARY | ONLY_DYNAMIC_LIBRARY]
    [ONLY_STATIC_CRT | ONLY_DYNAMIC_CRT]
)
```

## Parameters
### ONLY_STATIC_LIBRARY
Indicates that this port can only be built with static library linkage.

### ONLY_DYNAMIC_LIBRARY
Indicates that this port can only be built with dynamic/shared library linkage.

### ONLY_STATIC_CRT
Indicates that this port can only be built with static CRT linkage.

### ONLY_DYNAMIC_CRT
Indicates that this port can only be built with dynamic/shared CRT linkage.

## Notes
This command will either alter the settings for `VCPKG_LIBRARY_LINKAGE` or fail, depending on what was requested by the user versus what the library supports.

## Examples

* [abseil](https://github.com/Microsoft/vcpkg/blob/master/ports/abseil/portfile.cmake)
#]===]

function(vcpkg_check_linkage)
    cmake_parse_arguments(_csc "ONLY_STATIC_LIBRARY;ONLY_DYNAMIC_LIBRARY;ONLY_DYNAMIC_CRT;ONLY_STATIC_CRT" "" "" ${ARGN})

    if(_csc_ONLY_STATIC_LIBRARY AND VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        message(STATUS "Note: ${PORT} only supports static library linkage. Building static library.")
        set(VCPKG_LIBRARY_LINKAGE static PARENT_SCOPE)
    endif()
    if(_csc_ONLY_DYNAMIC_LIBRARY AND VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        message(STATUS "Note: ${PORT} only supports dynamic library linkage. Building dynamic library.")
        if(VCPKG_CRT_LINKAGE STREQUAL "static")
            message(FATAL_ERROR "Refusing to build unexpected dynamic library against the static CRT. If this is desired, please configure your triplet to directly request this configuration.")
        endif()
        set(VCPKG_LIBRARY_LINKAGE dynamic PARENT_SCOPE)
    endif()

    if(_csc_ONLY_DYNAMIC_CRT AND VCPKG_CRT_LINKAGE STREQUAL "static")
        message(FATAL_ERROR "${PORT} only supports dynamic crt linkage")
    endif()
    if(_csc_ONLY_STATIC_CRT AND VCPKG_CRT_LINKAGE STREQUAL "dynamic")
        message(FATAL_ERROR "${PORT} only supports static crt linkage")
    endif()
endfunction()
