vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Dobiasd/frugally-deep
    REF "v${VERSION}"
    SHA512 7490f7ede1fc138889992bfd859d552ba76677ae13d18622165ba6e3c3ffffa4e9169965e246050922f756361f1d97d1530f2dfdd15425a687c19078a2488ed3
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
