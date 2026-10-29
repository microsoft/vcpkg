vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO arximboldi/zug
    REF v${VERSION}
    SHA512 ffe55f2c0f026da4c5384f4f2cc7fbd661f38d7dfc3ad50cccf8010f78df9c6a81a9bf4b157c5d85104dc9fcc13fb51fb2c93a86a7a6a7e0ae87d1f14b0d3155
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        docs  zug_BUILD_DOCS
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Dzug_BUILD_EXAMPLES=OFF
        -Dzug_BUILD_TESTS=OFF
        ${FEATURE_OPTIONS}
)


vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/Zug)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
