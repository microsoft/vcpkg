vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO AOMediaCodec/libavif
    REF "v${VERSION}"
    SHA512 ba72b8d02b098f361643a073361fccafd22eaac14e46dd06378d5e7acd9853538c5d166473e1de0b020de62dac25be83e42bd57ba51f675d11e2ddf155fbfa21
    HEAD_REF master
    PATCHES
        disable-source-utf8.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        aom AVIF_CODEC_AOM
        dav1d AVIF_CODEC_DAV1D
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DAVIF_BUILD_APPS=OFF
        -DAVIF_BUILD_TESTS=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_libsharpyuv=ON
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
