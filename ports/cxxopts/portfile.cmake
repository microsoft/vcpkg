vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jarro2783/cxxopts
    REF "v${VERSION}"
    SHA512 7841fb3e6c3c2a057917c962e29fc0090e6ed06f5515aaa5e2a868fef59071a9a99b74d81c32cf613ecf10a68a4d96d6ad07805f48c7c3951ded096a2317dc3d
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCXXOPTS_BUILD_EXAMPLES=OFF
        -DCXXOPTS_BUILD_TESTS=OFF
        -DCXXOPTS_ENABLE_WARNINGS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/cxxopts)

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
