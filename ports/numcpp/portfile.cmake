# header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO dpilger26/NumCpp
    REF "Version_${VERSION}"
    SHA512 d0306fd8d329b92e8040e540a00187309986c50aa57030ed8a67e839c4f2b48322d28d938446c81362fd708c734b77015914b5913ea20acb722b2f67e72b37f8
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
