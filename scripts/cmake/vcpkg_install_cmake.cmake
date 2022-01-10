# DEPRECATED BY ports/vcpkg-cmake/vcpkg_cmake_install
#[===[.md:
# vcpkg_install_cmake

Build and install a cmake project.

## Usage:
```cmake
vcpkg_install_cmake(...)
```

## Parameters:
See [`vcpkg_build_cmake()`](vcpkg_build_cmake.md).

## Notes:
This command transparently forwards to [`vcpkg_build_cmake()`](vcpkg_build_cmake.md), adding a `TARGET install`
parameter.

## Examples:

* [zlib](https://github.com/Microsoft/vcpkg/blob/master/ports/zlib/portfile.cmake)
* [cpprestsdk](https://github.com/Microsoft/vcpkg/blob/master/ports/cpprestsdk/portfile.cmake)
* [poco](https://github.com/Microsoft/vcpkg/blob/master/ports/poco/portfile.cmake)
* [opencv](https://github.com/Microsoft/vcpkg/blob/master/ports/opencv/portfile.cmake)
#]===]

function(vcpkg_install_cmake)
    if(Z_VCPKG_CMAKE_INSTALL_GUARD)
        message(FATAL_ERROR "The ${PORT} port already depends on vcpkg-cmake; using both vcpkg-cmake and vcpkg_install_cmake in the same port is unsupported.")
    endif()

    cmake_parse_arguments(PARSE_ARGV 0 "arg" "DISABLE_PARALLEL;ADD_BIN_TO_PATH" "" "")
    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "vcpkg_cmake_install was passed extra arguments: ${arg_UNPARSED_ARGUMENTS}")
    endif()

    vcpkg_list(SET params)
    foreach(arg IN ITEMS DISABLE_PARALLEL ADD_BIN_TO_PATH)
        if(arg_${arg})
            vcpkg_list(APPEND params "${arg}")
        endif()
    endforeach()

    vcpkg_build_cmake(Z_VCPKG_DISABLE_DEPRECATION MESSAGE
        ${params}
        LOGFILE_ROOT install
        TARGET install
    )
endfunction()
