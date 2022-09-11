function(sqlcipher_generate_amalgamation SOURCE_PATH)
    file(TO_NATIVE_PATH "${SOURCE_PATH}" SOURCE_PATH_NAT)
    file(GLOB TCLSH_CMD ${CURRENT_HOST_INSTALLED_DIR}/tools/tcl/bin/tclsh*${VCPKG_HOST_EXECUTABLE_SUFFIX})
    message(STATUS "Generating amalgamation")

    if (CMAKE_HOST_WIN32)
        # Don't use vcpkg_build_nmake, because it doesn't handle nmake targets correctly.
        find_program(NMAKE nmake REQUIRED)
        vcpkg_execute_required_process(
            COMMAND ${NMAKE} -f Makefile.msc /A /NOLOGO clean sqlite3.c
            TCLSH_CMD="${TCLSH_CMD}"
            ORIGINAL_SRC="${SOURCE_PATH_NAT}"
            WORKING_DIRECTORY "${SOURCE_PATH}"
            LOGNAME amalgamation-${TARGET_TRIPLET}
        )
    else()
        vcpkg_execute_required_process(
            COMMAND ${SOURCE_PATH}/configure --with-crypto-lib=none TCLSH_CMD="${TCLSH_CMD}"
            WORKING_DIRECTORY "${SOURCE_PATH}"
            LOGNAME amalgamation-configure-${TARGET_TRIPLET}
        )
        vcpkg_execute_required_process(
            COMMAND make sqlite3.c
            WORKING_DIRECTORY "${SOURCE_PATH}"
            LOGNAME amalgamation-make-${TARGET_TRIPLET}
        )
    endif()

    message(STATUS "Generating amalgamation done")
endfunction()
