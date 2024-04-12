vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GPUOpen-LibrariesAndSDKs/D3D12MemoryAllocator 
    REF v${VERSION}
    SHA512 99d81cad82fe8c78cfbc7a2a611d31e3bb38df55ac938aec289d1085be2ec46129c74dd2f56c850f257c43c6bd122913910fb9512029a1b3ab4a02f2ed327931
    HEAD_REF master
    PATCHES
        0001-output-dirs.patch
        0002-Fix-32b-compilation.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH cmake/)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
