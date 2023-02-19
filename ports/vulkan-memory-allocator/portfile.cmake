vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GPUOpen-LibrariesAndSDKs/VulkanMemoryAllocator
    REF a6bfc237255a6bac1513f7c1ebde6d8aed6b5191 #v3.0.1
    SHA512  14361ff201fd660c22b60de54c648ff20a2e2a7f65105f66853a9a4dbffbeca2ae42098dcb1528bb4e524639b92fa4ff27ebd3940c42ccfaf7c99c08bdd0d8ce
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/include/vk_mem_alloc.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

file(COPY "${CMAKE_CURRENT_LIST_DIR}/unofficial-vulkan-memory-allocator-config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/unofficial-vulkan-memory-allocator")

configure_file("${SOURCE_PATH}/LICENSE.txt" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)
