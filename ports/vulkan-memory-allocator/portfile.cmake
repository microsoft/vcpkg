vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GPUOpen-LibrariesAndSDKs/VulkanMemoryAllocator
    REF "v${VERSION}"
    SHA512 deb5902ef8db0e329fbd5f3f4385eb0e26bdd9f14f3a2334823fb3fe18f36bc5d235d620d6e5f6fe3551ec3ea7038638899db8778c09f6d5c278f5ff95c3344b
    HEAD_REF master
)

set(opts "")
if(VCPKG_TARGET_IS_WINDOWS)
  set(opts "-DCMAKE_INSTALL_INCLUDEDIR=include/vma") # Vulkan SDK layout!
endif()

set(VCPKG_BUILD_TYPE release) # header-only port
vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS ${opts}

)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME VulkanMemoryAllocator CONFIG_PATH "share/cmake/VulkanMemoryAllocator")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
