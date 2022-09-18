vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wrobelda/libofx
    REF config_cmake
    SHA512 7bb85d4694f0de23dcfcc437bbf3138dc571f9caf30ab7ae9c2c8c2e006b72c720629ccb068427284be559e1fa46028eef5eac901096000492084d4a9eb31c9d
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