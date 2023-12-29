vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO socketio/socket.io-client-cpp
    REF b10474e3eaa6b27e75dbc1382ac9af74fdf3fa85
    SHA512 d0529c1fb293bd0a468d224f14e176fc80226dd665d2a947253beabc8fbe1b0b0a939778bce45a2d8f68d10583920329cf404f41d6fd5ccf2d176cec733e8996
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DUSE_SUBMODULES=OFF
        -DCMAKE_INSTALL_INCLUDEDIR=include
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME sioclient CONFIG_PATH lib/cmake/sioclient)
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/sioclient/sioclientConfig.cmake"
    "include(CMakeFindDependencyMacro)"
    [[include(CMakeFindDependencyMacro)
find_dependency(websocketpp CONFIG)
find_dependency(asio CONFIG)
find_dependency(RapidJSON CONFIG)
find_dependency(OpenSSL)]])

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
