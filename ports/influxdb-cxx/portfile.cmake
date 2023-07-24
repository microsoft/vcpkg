vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO offa/influxdb-cxx
    REF "v${VERSION}"
    SHA512 3be45353635df28803bd57927db292fc93db28fbec56007bbf694badcbfa277672b168c3b41cd228c9570a8b8f56212369ce7eabedca581307f4c8488a69ef27
    HEAD_REF master
    PATCHES fix-dllexports.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        boost   INFLUXCXX_WITH_BOOST
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DINFLUXCXX_TESTING=OFF
        -DINFLUXCXX_SYSTEMTEST=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_cmake_config_fixup(PACKAGE_NAME InfluxDB CONFIG_PATH lib/cmake/InfluxDB)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
