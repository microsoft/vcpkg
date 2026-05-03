vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Dobiasd/frugally-deep
    REF "v${VERSION}"
    SHA512 bfc632d35c30c209aed87bbd810c2c919609cef07af03fda50c17e8eb5eb735cbda9d49ec1e0685c3f8d322b870471bf02861d53300a22e177ca38639f4cee48
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
