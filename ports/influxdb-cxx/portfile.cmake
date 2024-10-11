vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO offa/influxdb-cxx
    REF 794eafce7a27036b83c71f90a9cb6a41758f32f8
    SHA512 f28898f655d50bfdd8460f47c5abf8c56c18f0520f574257e4eed4268a285f003114091f207b41dda5ee19c134ec06515160db12c7aceefaffa637ccec561643
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
