vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libofx/libofx
    REF 0.10.8
    SHA512 e241a9ad766a91f53a2b65c316e87ee43df9173b25904d1af05c2ce491c8d781278333c20206751787f540c7bc9880b32a41a4646714fd1586f22801394d89a3
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "iconv"       ENABLE_ICONV
        "ofxdump"     ENABLE_OFXDUMP
        "ofx2qif"     ENABLE_OFX2QIF
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DENABLE_OFXCONNECT=OFF # depends on libxml++ ABI 2.6, while vcpkg ships ABI 4.0. See https://libxmlplusplus.github.io/libxmlplusplus/#abi-versions
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(PACKAGE_NAME LibOFX CONFIG_PATH lib/cmake/libofx)
vcpkg_copy_pdbs()

list(REMOVE_ITEM FEATURES core iconv)
if(FEATURES)
    vcpkg_copy_tools(TOOL_NAMES ${FEATURES} AUTO_CLEAN)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
