vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO AOMediaCodec/libavif
    REF "v${VERSION}"
    SHA512 f7c35e40f9214314afeae69d5da6ab345e6dbd025e737a920ea4270452cdf7ff7010d7af5cc18d27e93b217114eb6b613cd349703d0e1bb7814dbeb84a9fd70f
    HEAD_REF master
    PATCHES
        disable-source-utf8.patch
        find-dependency.patch # from https://github.com/AOMediaCodec/libavif/pull/1339
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        aom AVIF_CODEC_AOM
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DAVIF_BUILD_APPS=OFF
        -DCMAKE_REQUIRE_FIND_PACKAGE_libyuv=ON
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

# Move cmake configs
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

# Fix pkg-config files
vcpkg_fixup_pkgconfig()

# Remove duplicate files
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include"
                    "${CURRENT_PACKAGES_DIR}/debug/share")

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
