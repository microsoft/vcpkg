vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO YaaZ/VulkanMemoryAllocator-Hpp
    REF "v${VERSION}+2"
    SHA512 141a2a8ef4b1bb7975d1690595ed4b3655a321cae9c44024dd0460820bf7a0bff40572b62437d2b5f2b9ba0778cecc4b941de82b091a0043422f14c5d0529b04
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/include/" DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}")

file(COPY "${CMAKE_CURRENT_LIST_DIR}/unofficial-vulkan-memory-allocator-hpp-config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/unofficial-${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
