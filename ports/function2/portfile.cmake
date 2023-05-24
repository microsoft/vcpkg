vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Naios/function2
    REF 2d3a878ef19dd5d2fb188898513610fac0a48621 # 4.2.2
    SHA512 e59c6fe7f4b68d4d70d1b0ccb3677ee5529e08431ee642933a4de1b217390d3a91f6501f06d0da080af85a5cb55da5b48c6de92818779ac25c6f56166a5b59fd
    HEAD_REF master
    PATCHES
        disable-testing.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")

file(REMOVE "${CURRENT_PACKAGES_DIR}/LICENSE.txt" "${CURRENT_PACKAGES_DIR}/Readme.md")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
