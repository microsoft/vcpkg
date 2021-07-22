vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GPUOpen-LibrariesAndSDKs/VulkanMemoryAllocator
    REF 55868965ae1fa956c07695d4642e1add8c9450f7
    SHA512 433d8a961a1fa4c80894f014fdfbbcafeb94932a3eea2eced9c7109dcbf7350a60efb9fb1d8f3c621f2d72c118f47f82f8e9e6f4db75038fbad3a727b5896479
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/include/vk_mem_alloc.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

file(COPY ${CMAKE_CURRENT_LIST_DIR}/unofficial-vulkan-memory-allocator-config.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/unofficial-vulkan-memory-allocator)

configure_file(${SOURCE_PATH}/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/vulkan-memory-allocator/copyright COPYONLY)
