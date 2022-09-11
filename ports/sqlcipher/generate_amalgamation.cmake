function(sqlcipher_generate_amalgamation SOURCE_PATH)
    vcpkg_find_acquire_program(TCL)
    file(TO_NATIVE_PATH "${SOURCE_PATH}" SOURCE_PATH_NAT)

    message(STATUS "Generating amalgamation")

    if (CMAKE_HOST_WIN32)
        # Don't use vcpkg_build_nmake, because it doesn't handle nmake targets correctly.
        find_program(NMAKE nmake REQUIRED)
        list(APPEND NMAKE_OPTIONS
            TCLSH_CMD="${TCL}"
            ORIGINAL_SRC="${SOURCE_PATH_NAT}"
        )
        
        vcpkg_execute_required_process(
            COMMAND ${NMAKE} -f Makefile.msc /A /NOLOGO clean sqlite3.c
            ${NMAKE_OPTIONS}
            WORKING_DIRECTORY "${SOURCE_PATH}"
            LOGNAME amalgamation-${TARGET_TRIPLET}
        )
    else()
        vcpkg_execute_required_process(
            COMMAND ${SOURCE_PATH_NAT}/configure --with-crypto-lib=none
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
