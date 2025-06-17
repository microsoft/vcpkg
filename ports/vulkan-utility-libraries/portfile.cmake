vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/Vulkan-Utility-Libraries
    REF "vulkan-sdk-${VERSION}"
    SHA512 9b875fecc295a45cdb8e6ff26345cf2b7df3959e2271e3f26546df3b415bf46a7bfd709ec482659fc86c35ff4314d7df482641f4c2e82e1b03f4c7ffc26d2a64
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
