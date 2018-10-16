include(vcpkg_common_functions)
set(SOURCE_PATH "${CURRENT_BUILDTREES_DIR}/src/VulkanMemoryAllocator-2.1.0")

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/GPUOpen-LibrariesAndSDKs/VulkanMemoryAllocator/archive/v2.1.0.zip"
    FILENAME "VulkanMemoryAllocator-2.1.0.zip"
    SHA512 1d3196fa5b03af6f1308244925f82cb365aee9995d70c27e074a5e534a495803fc9ef17ced54b73cd26324bba48f783d8966bc4c350cc3f32ff7c2cf3c1b0159
)
vcpkg_extract_source_archive(${ARCHIVE})

# copy (in place of install -- the source is not a cmake build) the sole include file
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/include")
file(COPY "${SOURCE_PATH}/src/vk_mem_alloc.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

set(_share_dir "${CURRENT_PACKAGES_DIR}/share/${PORT}")

# copyright
file(COPY "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${_share_dir}")
file(RENAME "${_share_dir}/LICENSE.txt" "${_share_dir}/copyright")

# usage
file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${_share_dir}")

# package config files
configure_file("${CURRENT_PORT_DIR}/vulkan-memory-allocator-config-version.cmake.in" "${_share_dir}/vulkan-memory-allocator-config-version.cmake.in" @ONLY)
configure_file("${CURRENT_PORT_DIR}/vulkan-memory-allocator-config.cmake.in" "${_share_dir}/vulkan-memory-allocator-config.cmake" @ONLY)
