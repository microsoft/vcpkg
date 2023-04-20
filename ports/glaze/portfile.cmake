vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stephenberry/glaze
    REF "v${VERSION}"
    SHA512 7943056d02711fbabddeaa84918171d552b9d17fdfb19e44e3a21cced565ba5ba04cc69257720228f6fd3daff2d7fd4455b0b20165642ae23b6eaafb068102e7
    PATCHES
      disable-dev-mode.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
