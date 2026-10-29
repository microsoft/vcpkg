vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO localcc/LightningScanner
    REF v${VERSION}
    SHA512 17e40a0aa42bfafb581f5812d15f9c0b4548d759548f336e686472b56ffb69afda323471c7525b2dcdebe9b128103534a5dbce0b1e61ed1f829664b3418b5147
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

