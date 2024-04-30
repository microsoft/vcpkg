vcpkg_download_distfile(PATCH_39
    URLS https://github.com/YaaZ/VulkanMemoryAllocator-Hpp/commit/73cdd838c425637c874d343ab0ceba5148189cbf.patch?full_index=1
    SHA512 6a00c6261fbef850ba9387557d9125e4f25e136ad6e1de203dc6e98bf1ef4a52adb444d9bfb9a92aef910d4eb4eb5b7292cfbc0add19d01ee481add27393f076
    FILENAME 9ebe4a22cad8a025b68a9594bdff3c047a111333.patch
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO YaaZ/VulkanMemoryAllocator-Hpp
    REF "v3.0.1-1"
    SHA512 71709a889ea4527c2ee273521fe62b61bb87cda3e3c3ae2964cc18bd70ac69629aeed00b1e92d4470ba6cb08394813880018401847a6d4ed5c15e4ee1fb60ff1
    HEAD_REF master
    PATCHES
        "${PATCH_39}"
)

file(COPY "${SOURCE_PATH}/include/" DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/unofficial-vulkan-memory-allocator-hpp-config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/unofficial-${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
