vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO TartanLlama/ranges
    REF 361dae81e48ea9d0099e8783b56b903c2a6cd01c
    SHA512 cce7964d1e77544495ae07c62c1b9a5e7948ea3a6d090e2e9126d3cbc685359e48425e48ddd533ba874ac442855f358d4b24db5265e1584aac6c54d63f82b6a4
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DRANGES_BUILD_TESTS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH share/cmake/tl-ranges)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/cmake")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
