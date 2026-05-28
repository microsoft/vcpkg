vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GPUOpen-LibrariesAndSDKs/D3D12MemoryAllocator 
    REF v${VERSION}
    SHA512 3275c3bed189adace00ee2b40feed61518380301e815a86040b357248c572399ad9c9cde025d20ba5e83214804b304f669ba0c33af3573584ed1ae63dab5872c
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
