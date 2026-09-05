vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO offa/influxdb-cxx
    REF "v${VERSION}"
    SHA512 bd21c67988fe3ffddcfe11c26c2d23954702a542f138751e78d027d98f980c5c8e969776a1697d6104a704c0dddf63130b9c1f9c9df6e8e6bcb27bf9f8303218
    HEAD_REF master
    PATCHES
        fix-dllexports.patch
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
        -DINFLUXCXX_INSTALL_HEADER_TO_SUBDIR=ON
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_cmake_config_fixup(PACKAGE_NAME InfluxDB CONFIG_PATH lib/cmake/InfluxDB)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
