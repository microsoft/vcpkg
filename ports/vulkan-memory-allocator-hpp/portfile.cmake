vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO YaaZ/VulkanMemoryAllocator-Hpp
    REF v3.0.1
    SHA512 0631319ec892161acb85903ddeecf0b18ff6772fdb44b46c756f6c148d150ea0850f7a35f105a04e9b23baf6ea5aa9bb373e04c7be598f1caa23c22cacf4ee00
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/include/" DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/unofficial-vulkan-memory-allocator-hpp-config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/unofficial-${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
