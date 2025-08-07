vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO offa/influxdb-cxx
    REF "v${VERSION}"
    SHA512 c2ff1b989e08d571d1ca29b78136c24d2759b787996bff05101527cf405835a15330812a26301714c960450f1ffaf984e4a6d76f608fba888b6a44142e79905d
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
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_cmake_config_fixup(PACKAGE_NAME InfluxDB CONFIG_PATH lib/cmake/InfluxDB)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
