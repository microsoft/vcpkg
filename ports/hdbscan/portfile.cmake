vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ooraloo/hdbscan-cpp-vcpkg
    REF "v${VERSION}"
    SHA512 d46b2c1f6eea353cedb2a734fb5fbed40ec42b90c931174e120fd4a97ca417d6eb11590c0cc89ee89cde6213043c6f1698d5c281c894ff11e7f1743deead473c
    HEAD_REF "master"
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()
vcpkg_install_copyright(FILE_LIST ${SOURCE_PATH}/LICENSE.md)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")