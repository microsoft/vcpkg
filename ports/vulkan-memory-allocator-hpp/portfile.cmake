vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO YaaZ/VulkanMemoryAllocator-Hpp
    REF "v${VERSION}+3"
    SHA512 14d853962f7410a6495c9a6c0cd7ce8b977e7eca5f4e243c9e442461d25d3e7d7671097e3962a7560af07a9618069eb01072e69a52220e61c21dc0deb52b9b75
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/include/" DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}")

file(COPY "${CMAKE_CURRENT_LIST_DIR}/unofficial-vulkan-memory-allocator-hpp-config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/unofficial-${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
