vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO "ta-lib/ta-lib"
    REF "${VERSION}"
    FILENAME "ta-lib-${VERSION}-msvc.zip"
    SHA512 5f211327b6a1d4f00d0a2b9e276adadd118d7aa29fc87c6771d550fda124a863b4a20e3803f325f7c903c82ea12bfb23121a5f0566eeaa434e0f107a6eedb737
)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
if(VCPKG_CRT_LINKAGE STREQUAL "dynamic")
    set(LFLAG "d")
else()
    set(LFLAG "m")
endif()

# Debug build
if (NOT VCPKG_BUILD_TYPE)
    vcpkg_execute_build_process(
        COMMAND nmake -f Makefile
        WORKING_DIRECTORY "${SOURCE_PATH}/c/make/c${LFLAG}d/win32/msvc"
        LOGNAME build-${TARGET_TRIPLET}-dbg
    )

    file(
        INSTALL "${SOURCE_PATH}/c/lib/ta_abstract_c${LFLAG}d.lib"
        DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib
        RENAME ta_abstract.lib
    )
    file(
        INSTALL "${SOURCE_PATH}/c/lib/ta_libc_c${LFLAG}d.lib"
        DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib
        RENAME ta_libc.lib
    )
    file(
        INSTALL "${SOURCE_PATH}/c/lib/ta_func_c${LFLAG}d.lib"
        DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib
        RENAME ta_func.lib
    )
    file(
        INSTALL "${SOURCE_PATH}/c/lib/ta_common_c${LFLAG}d.lib"
        DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib
        RENAME ta_common.lib
    )
endif()

# Release build
vcpkg_execute_build_process(
    COMMAND nmake -f Makefile
    WORKING_DIRECTORY "${SOURCE_PATH}/c/make/c${LFLAG}r/win32/msvc"
    LOGNAME build-${TARGET_TRIPLET}-rel
)

file(
    INSTALL "${SOURCE_PATH}/c/lib/ta_abstract_c${LFLAG}r.lib"
    DESTINATION ${CURRENT_PACKAGES_DIR}/lib
    RENAME ta_abstract.lib
)
file(
    INSTALL "${SOURCE_PATH}/c/lib/ta_libc_c${LFLAG}r.lib"
    DESTINATION ${CURRENT_PACKAGES_DIR}/lib
    RENAME ta_libc.lib
)
file(
    INSTALL "${SOURCE_PATH}/c/lib/ta_func_c${LFLAG}r.lib"
    DESTINATION ${CURRENT_PACKAGES_DIR}/lib
    RENAME ta_func.lib
)
file(
    INSTALL "${SOURCE_PATH}/c/lib/ta_common_c${LFLAG}r.lib"
    DESTINATION ${CURRENT_PACKAGES_DIR}/lib
    RENAME ta_common.lib
)

# Include files
file(
    INSTALL "${SOURCE_PATH}/c/include"
    DESTINATION ${CURRENT_PACKAGES_DIR}
    PATTERN Makefile.* EXCLUDE
)

# License file
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.TXT")
