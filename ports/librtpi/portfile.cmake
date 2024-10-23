vcpkg_from_gitlab(
    OUT_SOURCE_PATH SOURCE_PATH
    GITLAB_URL https://gitlab.com
    REPO linux-rt/librtpi
    REF "${VERSION}"
    SHA512 fb0cdd14f3c94f610fc153154ea09d5cfd7d3def16bdaabf8c2b4e0a8b7fa8ddec4cde6ae0b8726d58ee4a773df5c4f13002e565fb06ad3c8e9731a45122704f
    HEAD_REF main
    PATCHES
        condition_variable-fix-wait_until-predicate-evaluation.patch
)

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
)

vcpkg_install_make()
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(INSTALL "${CURRENT_PORT_DIR}/unofficial-${PORT}-config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/unofficial-${PORT}")
