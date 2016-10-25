function(vcpkg_apply_patches)
    cmake_parse_arguments(_ap "" "SOURCE_PATH" "PATCHES" ${ARGN})

    find_program(GIT git)
    set(PATCHNUM 0)
    foreach(PATCH ${_ap_PATCHES})
        message(STATUS "Applying patch ${PATCH}")
        set(LOGNAME patch-${TARGET_TRIPLET}-${PATCHNUM})
        execute_process(
            COMMAND ${GIT} --work-tree=. --git-dir=. apply "${PATCH}" --ignore-whitespace --whitespace=nowarn --verbose
            OUTPUT_FILE ${CURRENT_BUILDTREES_DIR}/${LOGNAME}-out.log
            ERROR_FILE ${CURRENT_BUILDTREES_DIR}/${LOGNAME}-err.log
            WORKING_DIRECTORY ${_ap_SOURCE_PATH}
            RESULT_VARIABLE error_code
        )
        
        if(error_code)
            message(STATUS
                "Applying patch failed: ${GIT} --work-tree=. --git-dir=. apply \"${PATCH}\" --ignore-whitespace --whitespace=nowarn --verbose\n"
                "-- Working Directory: ${_ap_SOURCE_PATH}\n"
                "-- This is expected if this patch was previously applied.\n"
                "-- See logs for more information: ${CURRENT_BUILDTREES_DIR}/${LOGNAME}-out.log ${CURRENT_BUILDTREES_DIR}/${LOGNAME}-err.log")
        endif()

        message(STATUS "Applying patch ${PATCH} done")
        math(EXPR PATCHNUM "${PATCHNUM}+1")
    endforeach()
endfunction()
