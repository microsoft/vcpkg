vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pyomeca/ezc3d
    REF "Release_${VERSION}"
    SHA512 aaab70cc589742b6a3f5a5d9586db40852e9dfd9f3328f2785e759711b3b0011455f97f872ad1b78529c5e5b9ea70bc440522e036a8d101ac5cf652d771c7404
    HEAD_REF dev
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_EXAMPLE=OFF
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/ezc3d")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
