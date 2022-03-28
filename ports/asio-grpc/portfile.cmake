vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Tradias/asio-grpc
    REF v1.5.0
    SHA512 0d7abc42bc37b6a42ac958481d046c72964e44e1f81d3dd872b3eebb23dc9ee090bbf2578b54d9ba23cfecbe7993a77ae65fd3fee095fc541e9ac6e79d1b6ee7
    HEAD_REF master
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        boost-container ASIO_GRPC_USE_BOOST_CONTAINER
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/asio-grpc)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")

file(INSTALL "${CURRENT_PORT_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
