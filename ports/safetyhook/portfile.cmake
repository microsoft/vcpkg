vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cursey/safetyhook
    REF "v${VERSION}"
    SHA512 29fe65c6c6a5fbf6c9fc8effbd33a04b08c88c09d009e2ea55a5d459ca0feaac4c8d09621b983f607f30fcb1a56a45f4e4843731362ff8375b6d1dcf84126f25
    HEAD_REF main
    PATCHES
        "fix-cmake-install.patch"
)

vcpkg_find_acquire_program(GIT)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DGIT_EXECUTABLE=${GIT}"
        "-DSAFETYHOOK_FETCH_ZYDIS=OFF"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/safetyhook)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
