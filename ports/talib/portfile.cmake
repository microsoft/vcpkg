vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO "TA-Lib/ta-lib"
    REF "v${VERSION}"
    SHA512 189702beda83f9ebe16ef7d08d8bba76068a71b63409e2e00f1a5a4a06997037d54f048778323fcc6482fe1e5ce9125314b4d4b7a12dee5d64c5b0d3879fca45
)

if(VCPKG_TARGET_IS_WINDOWS)
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
else()
    vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE)
    vcpkg_cmake_install()
    file(INSTALL
        "${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake"
        DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
    )
endif()
# License file
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
