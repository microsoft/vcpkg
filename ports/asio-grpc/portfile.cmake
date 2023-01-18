vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Tradias/asio-grpc
    REF v2.4.0
    SHA512 0aee11649d4df7c2f0964844b7f479eb6a1a8f51c1286345fdc14cba8581e951976cd48b1e00d1148b4fcf8519f578abb43038ba44996afd1de5195e24e22ee1
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
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
