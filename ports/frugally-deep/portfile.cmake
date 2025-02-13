vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Dobiasd/frugally-deep
    REF "v${VERSION}"
    SHA512 45cbdaa0a1aaaadb7472e18f25ebfaca6a9c3398adf15eb4bc96d2f56c504411ccf8db95b1fece077607c99d77d2d8d149e7da312063db7abf74baeadf35bdc1
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        double FDEEP_USE_DOUBLE
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
    -DFDEEP_BUILD_UNITTEST=OFF
    -DFDEEP_USE_TOOLCHAIN=ON
    ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/frugally-deep)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
