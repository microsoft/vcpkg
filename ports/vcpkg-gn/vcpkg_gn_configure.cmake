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

### OPTIONS_DEBUG
Options to be passed to the debug target.

### OPTIONS_RELEASE
Options to be passed to the release target.
#]===]

if(DEFINED Z_VCPKG_GN_CONFIGURE_GUARD)
    return()
endif()
set(Z_VCPKG_GN_CONFIGURE_GUARD ON)

function(vcpkg_gn_configure)
    cmake_parse_arguments(PARSE_ARGV 0 "arg"
      ""
      "SOURCE_PATH"
      "OPTIONS;OPTIONS_DEBUG;OPTIONS_RELEASE"
    )

    if(NOT DEFINED arg_SOURCE_PATH)
        message(FATAL_ERROR "SOURCE_PATH must be specified.")
    endif()

    vcpkg_find_acquire_program(PYTHON2)
    get_filename_component(PYTHON2_DIR "${PYTHON2}" DIRECTORY)
    vcpkg_add_to_path(PREPEND "${PYTHON2_DIR}")

    vcpkg_find_acquire_program(GN)

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        message(STATUS "Configuring ${TARGET_TRIPLET}-dbg")
        set(debug_args "${arg_OPTIONS}" "${arg_OPTIONS_DEBUG}")
        list(JOIN debug_args " " debug_args)
        vcpkg_execute_required_process(
            COMMAND "${GN}" gen "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg" "--args=${debug_args}"
            WORKING_DIRECTORY "${arg_SOURCE_PATH}"
            LOGNAME "configure-${TARGET_TRIPLET}-dbg"
        )
    endif()

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        message(STATUS "Configuring ${TARGET_TRIPLET}-rel")
        set(release_args "${arg_OPTIONS}" "${arg_OPTIONS_RELEASE}")
        list(JOIN release_args " " release_args)
        vcpkg_execute_required_process(
            COMMAND "${GN}" gen "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel" "--args=${release_args}"
            WORKING_DIRECTORY "${arg_SOURCE_PATH}"
            LOGNAME "configure-${TARGET_TRIPLET}-rel"
        )
    endif()
endfunction()
