vcpkg_from_gitlab(
    OUT_SOURCE_PATH SOURCE_PATH
    GITLAB_URL https://gitlab.com
    REPO linux-rt/librtpi
    REF "${VERSION}"
    SHA512 2665c32867f498d37daaec68a66f5d226de8c2f29bd57f784fbf33245aa5fc3dc173bb80d948b1b5c2c03798dce3fbd9638a3c0ec3816430ecfc7436cea9566e
    HEAD_REF main
)

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
)

vcpkg_install_make()
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(INSTALL "${CURRENT_PORT_DIR}/unofficial-${PORT}-config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/unofficial-${PORT}")
