vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO AOMediaCodec/libavif
    REF "v${VERSION}"
    SHA512 37f0de757180c6414778e688006940395960b316c25192d6beb97a07942aff4bd3b712dec2eff52cd26f5d72c352731442175dfeb90e2e1381133539760142b0
    HEAD_REF master
    PATCHES
        disable-source-utf8.patch
        find-dependency.patch # from https://github.com/AOMediaCodec/libavif/pull/1339
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
