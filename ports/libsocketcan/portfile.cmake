vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO linux-can/libsocketcan
    REF "v${VERSION}"
    SHA512 88669763ad43ab692ffe49be9335ee2a082dbb8d144e7452d01da66bb59866cd0c19b3c9d1b44c6df21c86d6e30c2b1aa6dd530499a9412bb92887a60023169b
    HEAD_REF master
)

vcpkg_execute_required_process(
        ALLOW_IN_DOWNLOAD_MODE
        COMMAND bash "${SOURCE_PATH}/autogen.sh"
        WORKING_DIRECTORY "${SOURCE_PATH}"
        LOGNAME autogen-${TARGET_TRIPLET}
)

vcpkg_configure_make(
        SOURCE_PATH "${SOURCE_PATH}"
        AUTOCONFIG
)

vcpkg_build_make(
        BUILD_TARGET all
        MAKEFILE GNUmakefile
)
vcpkg_install_make(
        MAKEFILE GNUmakefile
)
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

file(COPY "${CURRENT_PORT_DIR}/libsocketcanConfig.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/libsocketcan")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")