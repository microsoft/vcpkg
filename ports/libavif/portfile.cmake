vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO AOMediaCodec/libavif
    REF "v${VERSION}"
    SHA512 4a9e2711fccddf35c477db6e2fa2f76c0648aafaa98b4e3f34df62c0fbd02ddcd57762f1f8149822da4f1bc3757ee75ec1d9ced5e56a54dbe9d0b43265aacd4c
    HEAD_REF master
    PATCHES
        disable-source-utf8.patch
        fix-compiler-warnings.patch
        find-dependency.patch # from https://github.com/AOMediaCodec/libavif/pull/1339
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DAVIF_CODEC_AOM=ON
        -DAVIF_BUILD_APPS=OFF
        -DCMAKE_REQUIRE_FIND_PACKAGE_libyuv=ON
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
