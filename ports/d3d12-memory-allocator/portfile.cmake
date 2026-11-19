vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GPUOpen-LibrariesAndSDKs/D3D12MemoryAllocator
    REF "v${VERSION}"
    SHA512 7c6afbb3e5c96f4a3ce624a3dc0ca12ab051e7d77aa512baa1d00e760efdcbde2118ffef36c6f1cc3b0ca297f4e9578d4e7710f630b37de0482a28559a06c6da
    HEAD_REF master
    PATCHES
        0001-build-options.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DD3D12MA_USING_DIRECTX_HEADERS=ON
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(
    PACKAGE_NAME D3D12MemoryAllocator
    CONFIG_PATH share/cmake/D3D12MemoryAllocator/
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
