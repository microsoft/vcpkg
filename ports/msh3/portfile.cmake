vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nibanks/msh3
    REF #[[ v${VERSION} ]] 3aac7c0ca48a7286e13dbeb027687284950d7df7
    SHA512 03511ae2b8d9de9363a54f1d4bd4fa57a6d8c3a0e52ee3cc52efd93ac3dcb73bd294283abc2303026c10cbeea217a6cdfff0037d58a67d729f5f816b6fbc5335
    HEAD_REF main
    PATCHES
        dependencies_fix.patch
        win32-crt.diff
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
