vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GPUOpen-LibrariesAndSDKs/VulkanMemoryAllocator
    REF 42be483bd5c6605e789e011aac684e0b95d05359 #v3.0.0
    SHA512 5bb2240481511e51f1617f2c010a3e93a1c72a63713ed4aecf94488e7f46c78a3cfc591e8f94e14b1262b264bc06e1a78cfe69967b41e02441fad1a433747ee6
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/include/vk_mem_alloc.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

file(COPY "${CMAKE_CURRENT_LIST_DIR}/unofficial-vulkan-memory-allocator-config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/unofficial-vulkan-memory-allocator")

configure_file("${SOURCE_PATH}/LICENSE.txt" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)
