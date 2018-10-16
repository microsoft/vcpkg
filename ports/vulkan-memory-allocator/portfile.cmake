include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GPUOpen-LibrariesAndSDKs/VulkanMemoryAllocator
    REF v2.1.0
    SHA512 4d7d431d52503d4d448a8b571935678a8a04d8f4a7eceb6ad49cde4f78954e7a2a0a91e48c75382699a62d81cf00601aaa0a358d979ed8e14741a9956484b51e
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/src/vk_mem_alloc.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

file(COPY ${CMAKE_CURRENT_LIST_DIR}/unofficial-vulkan-memory-allocator-config.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/unofficial-vulkan-memory-allocator)

configure_file(${SOURCE_PATH}/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/vulkan-memory-allocator/copyright COPYONLY)
