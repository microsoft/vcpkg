#[===[.md:
# vcpkg_internal_get_cmake_vars

**Only for internal use in vcpkg helpers. Behavior and arguments will change without notice.**
Runs a cmake configure with a dummy project to extract certain cmake variables

## Usage
```cmake
vcpkg_internal_get_cmake_vars(
    [OUTPUT_FILE <output_file_with_vars>]
    [OPTIONS <-DUSE_THIS_IN_ALL_BUILDS=1>...]
)
```

## Parameters
### OPTIONS
Additional options to pass to the test configure call 

### OUTPUT_FILE
Variable to return the path to the generated cmake file with the detected `CMAKE_` variables set as `VCKPG_DETECTED_`

## Notes
If possible avoid usage in portfiles. 

## Examples

* [vcpkg_configure_make](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/vcpkg_configure_make.cmake)
#]===]

function(vcpkg_internal_get_cmake_vars)
    cmake_parse_arguments(PARSE_ARGV 0 _gcv "" "OUTPUT_FILE" "OPTIONS")

    if(_gcv_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} was passed unparsed arguments: '${_gcv_UNPARSED_ARGUMENTS}'")
    endif()

    if(NOT _gcv_OUTPUT_FILE)
        message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} requires parameter OUTPUT_FILE!")
    endif()

    if(${_gcv_OUTPUT_FILE})
        debug_message("OUTPUT_FILE ${${_gcv_OUTPUT_FILE}}")
    else()
        set(DEFAULT_OUT "${CURRENT_BUILDTREES_DIR}/cmake-vars-${TARGET_TRIPLET}.cmake.log") # So that the file gets included in CI artifacts.
        set(${_gcv_OUTPUT_FILE} "${DEFAULT_OUT}" PARENT_SCOPE)
        set(${_gcv_OUTPUT_FILE} "${DEFAULT_OUT}")
    endif()

    vcpkg_configure_cmake(
        SOURCE_PATH "${SCRIPTS}/get_cmake_vars"
        OPTIONS ${_gcv_OPTIONS} "-DVCPKG_BUILD_TYPE=${VCPKG_BUILD_TYPE}"
        OPTIONS_DEBUG "-DVCPKG_OUTPUT_FILE:PATH=${CURRENT_BUILDTREES_DIR}/cmake-vars-${TARGET_TRIPLET}-dbg.cmake.log"
        OPTIONS_RELEASE "-DVCPKG_OUTPUT_FILE:PATH=${CURRENT_BUILDTREES_DIR}/cmake-vars-${TARGET_TRIPLET}-rel.cmake.log"
        PREFER_NINJA
        LOGNAME get-cmake-vars-${TARGET_TRIPLET}
        Z_VCPKG_IGNORE_UNUSED_VARIABLES
    )

    set(_include_string)
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        string(APPEND _include_string "include(\"${CURRENT_BUILDTREES_DIR}/cmake-vars-${TARGET_TRIPLET}-rel.cmake.log\")\n")
    endif()
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        string(APPEND _include_string "include(\"${CURRENT_BUILDTREES_DIR}/cmake-vars-${TARGET_TRIPLET}-dbg.cmake.log\")\n")
    endif()
    file(WRITE "${${_gcv_OUTPUT_FILE}}" "${_include_string}")

endfunction()
