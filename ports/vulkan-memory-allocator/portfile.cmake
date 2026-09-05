vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GPUOpen-LibrariesAndSDKs/VulkanMemoryAllocator
    REF "v${VERSION}"
    SHA512 563acbcd8912d10d92c23715eba7acf0e7c1683af36021f415b36f359c2cce065f3906e395c32282a8410ec5c8179fbcb6412935c6629a49357475d4b4410e2a
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
