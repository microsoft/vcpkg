#.rst:
# .. command:: vcpkg_apply_patches
#
#  Apply a set of patches to a source tree.
#
#  ::
#  vcpkg_apply_patches(SOURCE_PATH <source_path>
#                      PATCHES patch1 [patch ...]
#                      )
#
#  ``SOURCE_PATH``
#    The source path in which apply the patches.
#  ``PATCHES``
#    A list of patches that are applied to the source tree
#  ``QUIET``
#    If this option is passed, the warning message when applyng
#    a patch fails is not printed. This is convenient for patches
#    that are known to fail even on a clean source tree, and for
#    which the standard warning message would be confusing for the user.
#

function(vcpkg_apply_patches)
    cmake_parse_arguments(_ap "QUIET" "SOURCE_PATH" "PATCHES" ${ARGN})

    find_program(GIT NAMES git git.cmd)
    set(PATCHNUM 0)
    foreach(PATCH ${_ap_PATCHES})
        message(STATUS "Applying patch ${PATCH}")
        set(LOGNAME patch-${TARGET_TRIPLET}-${PATCHNUM})
        execute_process(
            COMMAND ${GIT} --work-tree=. --git-dir=.git apply "${PATCH}" --ignore-whitespace --whitespace=nowarn --verbose
            OUTPUT_FILE ${CURRENT_BUILDTREES_DIR}/${LOGNAME}-out.log
            ERROR_FILE ${CURRENT_BUILDTREES_DIR}/${LOGNAME}-err.log
            WORKING_DIRECTORY ${_ap_SOURCE_PATH}
            RESULT_VARIABLE error_code
        )

        if(error_code AND NOT ${_ap_QUIET})
            message(STATUS "Applying patch failed. This is expected if this patch was previously applied.")
        endif()

        message(STATUS "Applying patch ${PATCH} done")
        math(EXPR PATCHNUM "${PATCHNUM}+1")
    endforeach()
endfunction()
