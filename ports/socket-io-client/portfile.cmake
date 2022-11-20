vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO socketio/socket.io-client-cpp
    REF dbb4547d3160368feaaf55c3338ad085a8f968b8
    SHA512 cbb2a4742d16ba9ee72ca49a56605690ed620c978f51012e0d655a86b110a557b196ffc55af8b0440c1d7cd76d9dffe6f85abd0af300095608434eb9394dc68b
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
