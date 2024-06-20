vcpkg_minimum_required(VERSION 2022-10-12)
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO netheril96/StaticJSON
    REF "v${VERSION}"
    SHA512 7d346b69c736aac11eec4fce6650c394dd388f551a359e77f26d80d1b7aa67670be993abe16f2d834263a87a1c116502a96ab6253cb18cab3aaa7d88a6d4d809
    HEAD_REF master
)
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSTATICJSON_ENABLE_TEST=OFF
)
vcpkg_cmake_install()
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
