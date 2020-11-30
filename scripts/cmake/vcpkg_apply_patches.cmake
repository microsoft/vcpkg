## # vcpkg_apply_patches
##
## Apply a set of patches to a source tree. This function is deprecated in favor of the `PATCHES` argument to `vcpkg_from_github()` et al.
##
## ## Usage
## ```cmake
## vcpkg_apply_patches(
##     SOURCE_PATH <${SOURCE_PATH}>
##     [QUIET]
##     PATCHES <patch1.patch>...
## )
## ```
##
## ## Parameters
## ### SOURCE_PATH
## The source path in which apply the patches. By convention, this is usually set in the portfile as the variable `SOURCE_PATH`.
##
## ### PATCHES
## A list of patches that are applied to the source tree.
##
## Generally, these take the form of `${CMAKE_CURRENT_LIST_DIR}/some.patch` to select patches in the `port\<port>\` directory.
##
## ### QUIET
## Disables the warning message upon failure.
##
## This should only be used for edge cases, such as patches that are known to fail even on a clean source tree.
##
## ## Examples
##
## * [libbson](https://github.com/Microsoft/vcpkg/blob/master/ports/libbson/portfile.cmake)
## * [gdal](https://github.com/Microsoft/vcpkg/blob/master/ports/gdal/portfile.cmake)

include(vcpkg_execute_in_download_mode)

function(vcpkg_apply_patches)
    # parse parameters such that semicolons in options arguments to COMMAND don't get erased
    cmake_parse_arguments(PARSE_ARGV 0 _ap "QUIET" "SOURCE_PATH" "PATCHES")

    find_program(GIT NAMES git git.cmd)
    if(DEFINED ENV{GIT_CONFIG_NOSYSTEM})
        set(GIT_CONFIG_NOSYSTEM_BACKUP "$ENV{GIT_CONFIG_NOSYSTEM}")
    else()
        unset(GIT_CONFIG_NOSYSTEM_BACKUP)
    endif()
    set(ENV{GIT_CONFIG_NOSYSTEM} 1)
    set(PATCHNUM 0)
    foreach(PATCH ${_ap_PATCHES})
        get_filename_component(ABSOLUTE_PATCH "${PATCH}" ABSOLUTE BASE_DIR "${CURRENT_PORT_DIR}")
        message(STATUS "Applying patch ${PATCH}")
        set(LOGNAME patch-${TARGET_TRIPLET}-${PATCHNUM})
        vcpkg_execute_in_download_mode(
            COMMAND ${GIT} --work-tree=. --git-dir=.git apply "${ABSOLUTE_PATCH}" --ignore-whitespace --whitespace=nowarn --verbose
            OUTPUT_FILE ${CURRENT_BUILDTREES_DIR}/${LOGNAME}-out.log
            ERROR_VARIABLE error
            WORKING_DIRECTORY ${_ap_SOURCE_PATH}
            RESULT_VARIABLE error_code
        )
        file(WRITE "${CURRENT_BUILDTREES_DIR}/${LOGNAME}-err.log" "${error}")

        if(error_code AND NOT _ap_QUIET)
            message(FATAL_ERROR "Applying patch failed. ${error}")
        endif()

        math(EXPR PATCHNUM "${PATCHNUM}+1")
    endforeach()
    if(DEFINED GIT_CONFIG_NOSYSTEM_BACKUP)
        set(ENV{GIT_CONFIG_NOSYSTEM} "${GIT_CONFIG_NOSYSTEM_BACKUP}")
    else()
        unset(ENV{GIT_CONFIG_NOSYSTEM})
    endif()
endfunction()
