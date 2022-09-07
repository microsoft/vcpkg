vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Tradias/asio-grpc
    REF v2.1.0
    SHA512 09a8a34406726057e2db8991a7156ce23e6f1f920d71a5716abcfd303b573929703a6e6af3a1ef6e9fe80ea6d9c7f2a072c6ffca6f06109afd09ab1277835e02
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
        -DASIO_GRPC_CMAKE_CONFIG_INSTALL_DIR=share/asio-grpc
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

file(INSTALL "${CURRENT_PORT_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
