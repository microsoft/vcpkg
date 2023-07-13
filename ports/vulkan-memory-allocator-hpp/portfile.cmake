vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO YaaZ/VulkanMemoryAllocator-Hpp
    REF "v3.0.1-1"
    SHA512 71709a889ea4527c2ee273521fe62b61bb87cda3e3c3ae2964cc18bd70ac69629aeed00b1e92d4470ba6cb08394813880018401847a6d4ed5c15e4ee1fb60ff1
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/include/" DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/unofficial-vulkan-memory-allocator-hpp-config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/unofficial-${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
