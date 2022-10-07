vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libofx/libofx
    REF 0.10.9
    SHA512 be7b77f77a012fe04121c615b88f674bba11f79b5353b3c4594de395f9f787c3a9b6910693f5ba701421387fc13c13e7977ab73893e18c6a0b6e1292b7d1cfe2
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
