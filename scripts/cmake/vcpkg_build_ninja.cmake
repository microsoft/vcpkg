#[===[.md:
# vcpkg_build_ninja

Build a ninja project

## Usage:
```cmake
vcpkg_build_ninja(
    [TARGETS <target>...]
)
```

## Parameters:
### TARGETS
Only build the specified targets.
#]===]

function(z_vcpkg_build_ninja_build config targets)
    message(STATUS "Building (${config})...")
    vcpkg_execute_build_process(
        COMMAND "${NINJA}" -C "${CURRENT_BUILDTREES_DIR}/${config}" ${targets}
        WORKING_DIRECTORY "${SOURCE_PATH}"
        LOGNAME "build-${config}"
    )
endfunction()


function(vcpkg_build_ninja)
    cmake_parse_arguments(PARSE_ARGV 0 arg "" "" "TARGETS")

    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(WARNING "${CMAKE_CURRENT_FUNCTION} was passed extra arguments: ${arg_UNPARSED_ARGUMENTS}")
    endif()
    if(NOT DEFINED arg_TARGETS)
        set(arg_TARGETS "")
    endif()

    vcpkg_find_acquire_program(NINJA)

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        z_vcpkg_build_ninja_build("${TARGET_TRIPLET}-dbg" "${arg_TARGETS}")
    endif()

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        z_vcpkg_build_ninja_build("${TARGET_TRIPLET}-rel" "${arg_TARGETS}")
    endif()
endfunction()
