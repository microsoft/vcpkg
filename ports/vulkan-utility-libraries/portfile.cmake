vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/Vulkan-Utility-Libraries
    REF "vulkan-sdk-${VERSION}"
    SHA512 67a696ebb961cf51414a255aad9fdf0bf5c9b8fff38e7824c73e5f33d8815b8bc9d22944a7d30d475ed7929464787c1ded93dbf23897826970bc4bef07268e49
    HEAD_REF main
)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    -DBUILD_TESTS:BOOL=OFF
)
vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/VulkanUtilityLibraries PACKAGE_NAME VulkanUtilityLibraries)
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/VulkanUtilityLibraries/VulkanUtilityLibrariesConfig.cmake"
    [[${PACKAGE_PREFIX_DIR}/lib/cmake/VulkanUtilityLibraries/VulkanUtilityLibraries-targets.cmake]]
    [[${CMAKE_CURRENT_LIST_DIR}/VulkanUtilityLibraries-targets.cmake]]
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
