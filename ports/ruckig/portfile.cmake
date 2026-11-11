vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pantor/ruckig
    REF "v${VERSION}"
    SHA512 f6008fa5d883d25841fd0264c58100775804388cecb4cf7706277c99d00e95b189c62e45c538595f525981ec95c99ccdf33d5a0bda2722a85832875e19b52952
    HEAD_REF main
    PATCHES
        third_party.patch
        cmake-dependencies.patch
        fix-constants.patch # See https://github.com/pantor/ruckig/pull/3 for the include-order limitation.
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


file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
