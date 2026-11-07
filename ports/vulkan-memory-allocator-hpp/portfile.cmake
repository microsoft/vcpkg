vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO YaaZ/VulkanMemoryAllocator-Hpp
    REF "v${VERSION}+1"
    SHA512 3b94742406aa7c20bc7bacd29c1c5a01686c9b15fb45d261e65707f4a009d3f0c97bc7121a5f0ea6fb9eebaecf3b8ba0e9d2d99a7adb86f8d7071fb5b0257085
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/include/" DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}")

file(COPY "${CMAKE_CURRENT_LIST_DIR}/unofficial-vulkan-memory-allocator-hpp-config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/unofficial-${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
