vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO localcc/LightningScanner
    REF v${VERSION}
    SHA512 7bd41e049ccdf1dbe39b2ab3c58344822300165482d7c5392fe1cd2b15a40baec9ff080963f7db60f2826ece983a06b921d8a28ba57edf751c2cc7644f0a1150
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

