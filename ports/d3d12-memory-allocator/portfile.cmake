vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GPUOpen-LibrariesAndSDKs/D3D12MemoryAllocator
    REF "v${VERSION}"
    SHA512 d8b9b3a587c676cee216a92f49ca965edbbbf321d87bf6d88e44e4b268aad8d7278601500c56f976d14c8960b4934279545e3e7ba625d6f94c321fef24b98844
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
