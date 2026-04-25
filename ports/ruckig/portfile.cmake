vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pantor/ruckig
    REF "v${VERSION}"
    SHA512 357b78a39b0ed0dde959aa7629af036d66e77ba3c0c4d0edb1f8fe3a6de4afca91bd4aecd316edd26d8b35a00e739f395850671374cd0f46743d4fe9a088f14b
    HEAD_REF main
    PATCHES
        third_party.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        cloud BUILD_CLOUD_CLIENT
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DBUILD_TESTS=OFF
        -DBUILD_EXAMPLES=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/ruckig")
vcpkg_copy_pdbs()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")