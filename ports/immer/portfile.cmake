# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO arximboldi/immer
    REF "v${VERSION}"
    SHA512 077778c9f5116031dfabb22343339193689c01fb45680f5f0c713ba712abe0c6fc77560a7e0e69d08b5064a2a716a900e0e04053c280fe03fd808d2358cf8738
    HEAD_REF master
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
