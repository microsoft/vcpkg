vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO DanielChappuis/reactphysics3d
    REF "v${VERSION}"
    SHA512 3ba9ec0e399d2dc46c126e4aa20718b9024f8097f36157e31b469f5135a726d3c0811e79335db970dfab7f258d1506dd4cefa46edca73f5940bf561dc9a5b11a
    HEAD_REF master
    PATCHES
        https://github.com/DanielChappuis/reactphysics3d/pull/421.patch?full_index=1
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME "ReactPhysics3D"
    CONFIG_PATH "lib/cmake/ReactPhysics3D"
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
