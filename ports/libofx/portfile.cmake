vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wrobelda/libofx
    REF config_cmake
    SHA512 f504430072d152a42c3a3fcd9ee7a11896fe671527fc56b421f0771c855b289ba31a9532eb0b7b6d1cd0f600786a5256e3040fcff6109b50d97d8461a509e389
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "ofxconnect"  ENABLE_OFXCONNECT
        "ofxdump"     ENABLE_OFXDUMP
        "ofx2qif"     ENABLE_OFX2QIF
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DENABLE_ICONV=ON
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(PACKAGE_NAME LibOFX CONFIG_PATH lib/cmake/libofx)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")