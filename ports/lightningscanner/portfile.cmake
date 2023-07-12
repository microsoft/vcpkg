vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO localcc/LightningScanner
    REF v${VERSION}
    SHA512 fa2aefb6a6097544f578a96592b7b2ff58d5bccac7b10a0ab45fbe87e1204b3cbde5c16c64974e7434ea385727fb150b39080bf809f9698d944f75a6c110fe3c
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DLIGHTNING_SCANNER_INSTALL=ON
        -DLIGHTNING_SCANNER_BUILD_BENCH=OFF
        -DLIGHTNING_SCANNER_BUILD_DOCS=OFF
        -DLIGHTNING_SCANNER_BUILD_TESTS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH share/cmake/LightningScanner)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

