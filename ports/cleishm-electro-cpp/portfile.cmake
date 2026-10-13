vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cleishm/electro-cpp
    REF "v${VERSION}"
    SHA512 ebae6a3d89ec816d2d689cbc839e75dd55c33517dcd2731ed45245ec4a9789f6d09421fa076f695da8036a14234675bdb927006bab8381e2df062de55b2c3f31
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DELECTRO_BUILD_TESTS=OFF
        -DELECTRO_BUILD_DOCS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME electro CONFIG_PATH lib/cmake/electro)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug"
    "${CURRENT_PACKAGES_DIR}/lib"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
