function(vcpkg_build_cmake)
    message(STATUS "Build ${TARGET_TRIPLET}-rel")
    vcpkg_execute_required_process(
        COMMAND ${CMAKE_COMMAND} --build . --config Release -- /p:VCPkgLocalAppDataDisabled=true /m
        WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel
        LOGNAME build-${TARGET_TRIPLET}-rel
    )
    message(STATUS "Build ${TARGET_TRIPLET}-rel done")

    message(STATUS "Build ${TARGET_TRIPLET}-dbg")
    vcpkg_execute_required_process(
        COMMAND ${CMAKE_COMMAND} --build . --config Debug -- /p:VCPkgLocalAppDataDisabled=true /m
        WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg
        LOGNAME build-${TARGET_TRIPLET}-dbg
    )
    message(STATUS "Build ${TARGET_TRIPLET}-dbg done")
endfunction()
