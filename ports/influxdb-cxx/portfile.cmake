vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO offa/influxdb-cxx
    REF v0.6.6
    SHA512 4c9a9bf7ccf430caaed088830dceda8cc4b4ec6b78187e5238c5e73f17583781d9d00e08db1011b86a4f418cdfbbfc8b000500461d013872a62096de456e47ea
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        boost   INFLUXCXX_WITH_BOOST
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DINFLUXCXX_TESTING=OFF
        -DINFLUXCXX_SYSTEMTEST=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_install_cmake()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
