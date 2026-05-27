vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO dmtx/libdmtx
    REF v${VERSION}
    SHA512 2796b2a43d2e83732bd9e9c3d4c702c3b40f55453713d968cf8927534952af3891c8e1f650650e4d47e9c58f50b23f43e2653e2b9ea474359a00dcd097b6bf00
    PATCHES
        001-cmake-add-install-target.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
