vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Tradias/asio-grpc
    REF v1.6.0
    SHA512 4ea06c09c869cb1752714f969366d794b67048b42bff0790543d3305ce656238a4dadd06dfff1c2229add8a0ff730f30c70d944681979e3e983d4ec1d3ce3208
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
