## # vcpkg_build_ninja
##
## Build a ninja project
##
## ## Usage:
## ```cmake
## vcpkg_build_ninja(
##     [TARGETS <target>...]
## )
## ```
##
## ## Parameters:
## ### TARGETS
## Only build the specified targets.

function(vcpkg_build_ninja)
    cmake_parse_arguments(_vbn "" "" "TARGETS" ${ARGN})

    vcpkg_find_acquire_program(NINJA)

    function(build CONFIG)
        message(STATUS "Building (${CONFIG})...")
        vcpkg_execute_build_process(
            COMMAND "${NINJA}" -C "${CURRENT_BUILDTREES_DIR}/${CONFIG}" ${_vbn_TARGETS}
            WORKING_DIRECTORY "${SOURCE_PATH}"
            LOGNAME build-${CONFIG}
        )
    endfunction()

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        build(${TARGET_TRIPLET}-dbg)
    endif()

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        build(${TARGET_TRIPLET}-rel)
    endif()
endfunction()