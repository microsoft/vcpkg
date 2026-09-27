vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GPUOpen-LibrariesAndSDKs/D3D12MemoryAllocator 
    REF v${VERSION}
    SHA512 2dd282d1c297e02b21b46651588f2b3614b96aaad1f89b0616f55b405eaf9674d54827f09912716bcf06bfae363e444d05755a1c2b3bbe47820a721de4b5bebc
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
