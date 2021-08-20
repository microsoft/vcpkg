#[===[.md:
# vcpkg_cmake_get_vars

Runs a cmake configure with a dummy project to extract certain cmake variables

## Usage
```cmake
vcpkg_cmake_get_vars(<out-var>)
```

`vcpkg_cmake_get_vars(<out-var>)` sets `<out-var>` to
a path to a generated CMake file, with the detected `CMAKE_*` variables
re-exported as `VCPKG_DETECTED_CMAKE_*`.

## Notes
Avoid usage in portfiles.

All calls to `vcpkg_cmake_get_vars` will result in the same output file;
the output file is not generated multiple times.

### Basic Usage

```cmake
vcpkg_cmake_get_vars(cmake_vars_file)
include("${cmake_vars_file}")
message(STATUS "detected CXX flags: ${VCPKG_DETECTED_CMAKE_CXX_FLAGS}")
```
#]===]

set(Z_VCPKG_CMAKE_GET_VARS_CURRENT_LIST_DIR "${CMAKE_CURRENT_LIST_DIR}")

function(vcpkg_cmake_get_vars out_file)
    cmake_parse_arguments(PARSE_ARGV 1 arg "" "" "")

    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} was passed extra arguments: ${arg_UNPARSED_ARGUMENTS}")
    endif()

    if(NOT DEFINED CACHE{Z_VCPKG_CMAKE_GET_VARS_FILE})
        set(Z_VCPKG_CMAKE_GET_VARS_FILE "${CURRENT_BUILDTREES_DIR}/cmake-get-vars-${TARGET_TRIPLET}.cmake.log"
            CACHE PATH "The file to include to access the CMake variables from a generated project.")
        vcpkg_cmake_configure(
            SOURCE_PATH "${Z_VCPKG_CMAKE_GET_VARS_CURRENT_LIST_DIR}/cmake_get_vars"
            OPTIONS_DEBUG "-DVCPKG_OUTPUT_FILE:PATH=${CURRENT_BUILDTREES_DIR}/cmake-get-vars-${TARGET_TRIPLET}-dbg.cmake.log"
            OPTIONS_RELEASE "-DVCPKG_OUTPUT_FILE:PATH=${CURRENT_BUILDTREES_DIR}/cmake-get-vars-${TARGET_TRIPLET}-rel.cmake.log"
            LOGFILE_BASE cmake-get-vars-${TARGET_TRIPLET}
            Z_CMAKE_GET_VARS_USAGE # be quiet, don't set variables...
        )

        set(include_string "")
        if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
            string(APPEND include_string "include(\"\${CMAKE_CURRENT_LIST_DIR}/cmake-get-vars-${TARGET_TRIPLET}-rel.cmake.log\")\n")
        endif()
        if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
            string(APPEND include_string "include(\"\${CMAKE_CURRENT_LIST_DIR}/cmake-get-vars-${TARGET_TRIPLET}-dbg.cmake.log\")\n")
        endif()
        file(WRITE "${Z_VCPKG_CMAKE_GET_VARS_FILE}" "${include_string}")
    endif()

    set("${out_file}" "${Z_VCPKG_CMAKE_GET_VARS_FILE}" PARENT_SCOPE)
endfunction()
