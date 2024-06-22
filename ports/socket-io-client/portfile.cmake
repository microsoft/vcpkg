vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO socketio/socket.io-client-cpp
    REF 0dc2f7afea17a0e5bfb5e9b1e6d6f26ab1455cef
    SHA512 583cc0c6e392243203e4d10163a1cb5a404497472e684dfbeef7ca9634784a1fe4717f926858eea98aa0ac4356fb503abfbbeb58fcb1dd839c917e9f6ee104b1
    HEAD_REF master
    PATCHES
        fix-build.patch
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
