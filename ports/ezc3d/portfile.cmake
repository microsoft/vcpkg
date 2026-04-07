vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pyomeca/ezc3d
    REF "Release_${VERSION}"
    SHA512 3ca1bde573274eae04ad50fcd7431bc133518249a540de3a0ce1ccc68c48ed51c0c558c510229507f509c072a6a7fe8ce0c1eca5416c7d5611d3930a5a1b236a
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
