set(VCPKG_BUILD_TYPE release)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stillwater-sc/universal
    REF "v${VERSION}"
    SHA512 49dd6be95cdff4d8aefbb1a87dff66ffae118adaa16c3d2104d258d5a142c82f76282363a3a776e4545a6609a187c5027be93c5fed5c256ba074a9e78b7b29f0
    HEAD_REF master
    PATCHES
        fix-install-path.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DUNIVERSAL_ENABLE_TESTS=OFF
        -DUNIVERSAL_VERBOSE_BUILD=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH CMake PACKAGE_NAME universal)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/include/universal/internal/variablecascade"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

