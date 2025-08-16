vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pyomeca/ezc3d
    REF "Release_${VERSION}"
    SHA512 4fe9503bf1206a282e015bc8e1f49f83be7b00bdc85733217d9090ff13660e644143bfcb695c9cbdaf0bd12a54755f8e484b01724931660d067c940c772cde05
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
