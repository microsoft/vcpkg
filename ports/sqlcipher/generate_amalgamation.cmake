function(sqlcipher_generate_amalgamation SOURCE_PATH)
    file(TO_NATIVE_PATH "${SOURCE_PATH}" SOURCE_PATH_NAT)
    file(GLOB TCLSH_CMD ${CURRENT_HOST_INSTALLED_DIR}/tools/tcl/bin/tclsh*${VCPKG_HOST_EXECUTABLE_SUFFIX})
    vcpkg_add_to_path(PREPEND "${CURRENT_HOST_INSTALLED_DIR}/tools/lemon")
    message(STATUS "Generating amalgamation")

    #[[
    Using target triplet check isn't ideal, since this would fail when cross
    compiling to Linux from Windows for example, but that use case probably
    isn't very common
    ]]
    if (CMAKE_HOST_WIN32 AND VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
        # Don't use vcpkg_build_nmake, because it doesn't handle nmake targets correctly.
        find_program(NMAKE nmake REQUIRED)
        vcpkg_execute_required_process(
            COMMAND "${NMAKE}" -f Makefile.msc /A /NOLOGO clean sqlite3.c
            TCLSH_CMD="${TCLSH_CMD}"
            ORIGINAL_SRC="${SOURCE_PATH_NAT}"
            WORKING_DIRECTORY "${SOURCE_PATH}"
            LOGNAME amalgamation-${TARGET_TRIPLET}
        )
    else()
        if (CMAKE_HOST_WIN32)
            vcpkg_acquire_msys(MSYS_ROOT)
            set(SHELL "${MSYS_ROOT}/usr/bin/sh.exe")
        else()
            set(SHELL "sh")
        endif()
        vcpkg_execute_required_process(
            COMMAND "${SHELL}" "${SOURCE_PATH}/configure" --with-crypto-lib=none TCLSH_CMD="${TCLSH_CMD}"
            WORKING_DIRECTORY "${SOURCE_PATH}"
            LOGNAME amalgamation-configure-${TARGET_TRIPLET}
        )

        find_program(MAKE gmake)
        if (NOT MAKE)
            find_program(MAKE make)
        endif()
        if (NOT MAKE)
            message(FATAL_ERROR "Cannot find make or gmake, please install it from your package manager")
        endif()
        vcpkg_execute_required_process(
            COMMAND "${MAKE}" sqlite3.c
            WORKING_DIRECTORY "${SOURCE_PATH}"
            LOGNAME amalgamation-make-${TARGET_TRIPLET}
        )
    endif()

    message(STATUS "Generating amalgamation done")
endfunction()
