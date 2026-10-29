vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO dmtx/libdmtx
    REF v${VERSION}
    SHA512 2796b2a43d2e83732bd9e9c3d4c702c3b40f55453713d968cf8927534952af3891c8e1f650650e4d47e9c58f50b23f43e2653e2b9ea474359a00dcd097b6bf00
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" DMTX_SHARED)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" DMTX_STATIC)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DDMTX_SHARED=${DMTX_SHARED}
        -DDMTX_STATIC=${DMTX_STATIC}
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
