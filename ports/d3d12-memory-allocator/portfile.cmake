vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GPUOpen-LibrariesAndSDKs/D3D12MemoryAllocator 
    REF v${VERSION}
    SHA512 58d44aa021a04c1fa82cf5ff76420de43091d5475da9c23975176058990e0e3e1106aa13042ea6e75d29dd71f821b5431f9f12b62fba5e58955aa30127b4221b
    HEAD_REF master
    PATCHES "0001-build-options.patch"
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(
    PACKAGE_NAME D3D12MemoryAllocator
    CONFIG_PATH share/cmake/D3D12MemoryAllocator/
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
