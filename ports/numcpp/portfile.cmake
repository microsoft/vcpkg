# header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO dpilger26/NumCpp
    REF "Version_${VERSION}"
    SHA512 eb964cc31e8abb32021bd5c55b2a5e3957d375de5d23ce471304a242040f3f9dddc9014d5fc23a6dea45b3701a287e280e3b2db95cfcf1e2b2a707636d0ee9b5
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    INVERTED_FEATURES
        boost NUMCPP_NO_USE_BOOST
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME NumCpp CONFIG_PATH share/NumCpp/cmake)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
