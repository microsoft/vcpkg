vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO offa/influxdb-cxx
    REF "v${VERSION}"
    SHA512 ac16178a17ac9b43a23d64f56d0012aeda896d3065246166abdef1441cf466453a6972c5820411936dcfa10a21505b654dfe981449c1d4cc169807f1db5d099f
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
