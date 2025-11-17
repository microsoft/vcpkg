vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pyomeca/ezc3d
    REF "Release_${VERSION}"
    SHA512 36c0a3ebd3d1a6f60d842dd459cb87f6fb2ff39b63f1b6b193f4a0359a83da3ad1435fc3e33bb9f8319cedd743e8587fcde3e854f915a9ee5c1851cd64bf786e
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
