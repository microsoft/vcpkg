#[===[.md:
# vcpkg_configure_gn

Generate Ninja (GN) targets

## Usage:
```cmake
vcpkg_configure_gn(
    SOURCE_PATH <SOURCE_PATH>
    [OPTIONS <OPTIONS>]
    [OPTIONS_DEBUG <OPTIONS_DEBUG>]
    [OPTIONS_RELEASE <OPTIONS_RELEASE>]
)
```

## Parameters:
### SOURCE_PATH (required)
The path to the GN project.

### OPTIONS
Options to be passed to both the debug and release targets.
Note: Must be provided as a space-separated string.

### OPTIONS_DEBUG (space-separated string)
Options to be passed to the debug target.

### OPTIONS_RELEASE (space-separated string)
Options to be passed to the release target.
#]===]

function(vcpkg_configure_gn)
    # parse parameters such that semicolons in options arguments to COMMAND don't get erased
    cmake_parse_arguments(PARSE_ARGV 0 _vcg "" "SOURCE_PATH;OPTIONS;OPTIONS_DEBUG;OPTIONS_RELEASE" "")

    if(NOT DEFINED _vcg_SOURCE_PATH)
        message(FATAL_ERROR "SOURCE_PATH must be specified.")
    endif()

    vcpkg_find_acquire_program(PYTHON2)
    get_filename_component(PYTHON2_DIR "${PYTHON2}" DIRECTORY)
    vcpkg_add_to_path(PREPEND "${PYTHON2_DIR}")

    vcpkg_find_acquire_program(GN)

    function(generate CONFIG ARGS)
        message(STATUS "Generating build (${CONFIG})...")
        vcpkg_execute_required_process(
            COMMAND "${GN}" gen "${CURRENT_BUILDTREES_DIR}/${CONFIG}" ${ARGS}
            WORKING_DIRECTORY "${SOURCE_PATH}"
            LOGNAME generate-${CONFIG}
        )
    endfunction()

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        generate(${TARGET_TRIPLET}-dbg "--args=${_vcg_OPTIONS} ${_vcg_OPTIONS_DEBUG}")
    endif()

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        generate(${TARGET_TRIPLET}-rel "--args=${_vcg_OPTIONS} ${_vcg_OPTIONS_RELEASE}")
    endif()
endfunction()
