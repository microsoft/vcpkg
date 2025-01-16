vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pantor/ruckig
    REF "v${VERSION}"
    SHA512 cd8e31d4cc41cf90a23095f39f58e7139ac12a34c7699f3274c6389916cbed56a6e8627facaf34e5a888d43b78e43cb01dce1cd1ef45201652d3ded917a80075
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_CLOUD_CLIENT=OFF
        -DBUILD_TESTS=OFF
        -DBUILD_EXAMPLES=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/ruckig")
vcpkg_copy_pdbs()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")