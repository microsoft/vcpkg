vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GPUOpen-LibrariesAndSDKs/VulkanMemoryAllocator
    REF "v${VERSION}"
    SHA512 34534807bb76e6d2ab178b1613811ff654bcf9f9050b8ba9744d1012d39e65ce89b5f117ac7598a1efc458149b3544b1a6ad356ab6d850600aa198f519cba315
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
