# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO arximboldi/immer
    REF "v${VERSION}"
    SHA512 fc34242d36efdb9faa1f22ccc7591c1ace34c2b383e1266a290346baedc154e3d4a682d6dd5094460b75e123347194710072e996d19165cc5fd23c922fdfc4e8
    HEAD_REF master
    PATCHES
        fix-ExportConfigVersion.patch # Upstream PR https://github.com/arximboldi/immer/pull/250 has been merged, this patch need to be removed in next update.
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "docs"  immer_BUILD_DOCS
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DENABLE_PYTHON=OFF
        -DENABLE_GUILE=OFF
        -DENABLE_BOOST_COROUTINE=OFF
        -Dimmer_BUILD_TESTS=OFF
        -Dimmer_BUILD_EXAMPLES=OFF
        -Dimmer_BUILD_EXTRAS=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/Immer)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
