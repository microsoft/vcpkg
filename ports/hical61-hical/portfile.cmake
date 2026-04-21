vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Hical61/Hical
    REF "v${VERSION}"
    SHA512 db6f41e68efc0cf7f7d0e76bd7cb4f87555e996e4c64aa8f83fdbcb57075448fa4a2598a594cc310b50b6862c50782aa53d1746dcb87d64f28524663c344aae7
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DHICAL_BUILD_TESTS=OFF
        -DHICAL_BUILD_EXAMPLES=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME hical
    CONFIG_PATH lib/cmake/hical
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
