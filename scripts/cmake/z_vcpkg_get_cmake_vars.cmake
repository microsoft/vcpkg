#[===[.md:
# z_vcpkg_get_cmake_vars

**Only for internal use in vcpkg helpers. Behavior and arguments will change without notice.**
Runs a cmake configure with a dummy project to extract certain cmake variables

## Usage
```cmake
z_vcpkg_get_cmake_vars(<out-var>)
```

`z_vcpkg_get_cmake_vars(cmake_vars_file)` sets `<out-var>` to
a path to a generated CMake file, with the detected `CMAKE_*` variables
re-exported as `VCPKG_DETECTED_*`.

## Notes
Avoid usage in portfiles. 

All calls to `z_vcpkg_get_cmake_vars` will result in the same output file;
the output file is not generated multiple times.

## Examples

* [vcpkg_configure_make](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/vcpkg_configure_make.cmake)

### Basic Usage

```cmake
z_vcpkg_get_cmake_vars(cmake_vars_file)
include("${cmake_vars_file}")
message(STATUS "detected CXX flags: ${VCPKG_DETECTED_CXX_FLAGS}")
```
#]===]

function(z_vcpkg_get_cmake_vars out_file)
    cmake_parse_arguments(PARSE_ARGV 1 arg "" "" "")

    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} was passed extra arguments: ${arg_UNPARSED_ARGUMENTS}")
    endif()

    if(NOT DEFINED CACHE{Z_VCPKG_GET_CMAKE_VARS_FILE})
        set(Z_VCPKG_GET_CMAKE_VARS_FILE "${CURRENT_BUILDTREES_DIR}/cmake-vars-${TARGET_TRIPLET}.cmake.log"
            CACHE PATH "The file to include to access the CMake variables from a generated project.")
        vcpkg_configure_cmake(
            SOURCE_PATH "${SCRIPTS}/get_cmake_vars"
            OPTIONS_DEBUG "-DVCPKG_OUTPUT_FILE:PATH=${CURRENT_BUILDTREES_DIR}/cmake-vars-${TARGET_TRIPLET}-dbg.cmake.log"
            OPTIONS_RELEASE "-DVCPKG_OUTPUT_FILE:PATH=${CURRENT_BUILDTREES_DIR}/cmake-vars-${TARGET_TRIPLET}-rel.cmake.log"
            PREFER_NINJA
            LOGNAME get-cmake-vars-${TARGET_TRIPLET}
            Z_GET_CMAKE_VARS_USAGE # ignore vcpkg_cmake_configure, be quiet, don't set variables...
        )

        set(include_string "")
        if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
            string(APPEND include_string "include(\"\${CMAKE_CURRENT_LIST_DIR}/cmake-vars-${TARGET_TRIPLET}-rel.cmake.log\")\n")
        endif()
        if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
            string(APPEND include_string "include(\"\${CMAKE_CURRENT_LIST_DIR}/cmake-vars-${TARGET_TRIPLET}-dbg.cmake.log\")\n")
        endif()
        file(WRITE "${Z_VCPKG_GET_CMAKE_VARS_FILE}" "${include_string}")
    endif()

    set("${out_file}" "${Z_VCPKG_GET_CMAKE_VARS_FILE}" PARENT_SCOPE)
endfunction()
