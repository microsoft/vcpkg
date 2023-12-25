#header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO artivis/manif
    REF bb3f6758ae467b7f24def71861798d131f157032
    SHA512 aaead27e1a177a1ded644bac270702c7d6232ac5345148be41d3ebca7e181d194e106d74f175182af51a72a4f26d5632749306d86676b5cb8862ddc34ea16a05
    HEAD_REF devel
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH share/manif/cmake)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
