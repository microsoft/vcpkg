vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cleishm/spatial-cpp
    REF "v${VERSION}"
    SHA512 6d1ed19a54bd6c1bda8a6a99074139edf1e931f72e10a3448e737abe07323310e4cfff11115a6f9229fb3f89d8b71c5fda073b6739fa05bdc0140afd6e0ae447
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSPATIAL_BUILD_TESTS=OFF
        -DSPATIAL_BUILD_DOCS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME spatial CONFIG_PATH lib/cmake/spatial)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug"
    "${CURRENT_PACKAGES_DIR}/lib"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
