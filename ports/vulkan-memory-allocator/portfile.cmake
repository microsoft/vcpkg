include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GPUOpen-LibrariesAndSDKs/VulkanMemoryAllocator
    REF v2.2.0
    SHA512 85b49a1c55f469fd7340075809b045507db162b7dc663b885d963e3b3fd17759608401d353d3460f2ebf771e97f89af46e409cf9f5186325c3ce2c68d9b7e08f
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/src/vk_mem_alloc.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

file(COPY ${CMAKE_CURRENT_LIST_DIR}/unofficial-vulkan-memory-allocator-config.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/unofficial-vulkan-memory-allocator)

configure_file(${SOURCE_PATH}/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/vulkan-memory-allocator/copyright COPYONLY)
