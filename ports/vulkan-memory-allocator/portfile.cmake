include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GPUOpen-LibrariesAndSDKs/VulkanMemoryAllocator
    REF v2.3.0+vs2017
    SHA512 57113c52dcccc4df79ebf36f091f1232f68ee45c48934a5b91c2d87b5599d8c176ca7a47e285ddf146ec0b3c83db5808c2e6c3f6e1b453e20a8525f73211bf8d
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/src/vk_mem_alloc.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

file(COPY ${CMAKE_CURRENT_LIST_DIR}/unofficial-vulkan-memory-allocator-config.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/unofficial-vulkan-memory-allocator)

configure_file(${SOURCE_PATH}/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/vulkan-memory-allocator/copyright COPYONLY)
