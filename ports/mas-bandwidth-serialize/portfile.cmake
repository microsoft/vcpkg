# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mas-bandwidth/serialize
    REF "v${VERSION}"
    SHA512 b2a62698e73a77823d4274d8dac36d5876f69b8b5f3542092903e72bed0dc68f52a1a58cf895acf8bd736b27f2ed310df4568736eb8ae0ac805f1d0ec834b948
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSERIALIZE_BUILD_TESTS=OFF
        -DSERIALIZE_INSTALL=ON
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME serialize CONFIG_PATH lib/cmake/serialize)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug"
    "${CURRENT_PACKAGES_DIR}/lib"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
