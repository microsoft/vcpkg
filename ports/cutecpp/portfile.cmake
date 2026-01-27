vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jkCXf9X4/cutecpp
    REF "${VERSION}"
    SHA512 0b67421246a83ee32fa28b0e88369f07390c863e8e1aa4c34b2e210156ebf4c671139e2e173a7d5d6b1f938bc52184c3cc5fbe81f360a4398bb7efc6f63e67d4
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCUTECPP_BUILD_TESTS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME cutecpp
    CONFIG_PATH lib/cmake/cutecpp
)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(
    FILE_LIST "${SOURCE_PATH}/LICENSE"
)
