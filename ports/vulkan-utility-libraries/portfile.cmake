vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/Vulkan-Utility-Libraries
    REF "vulkan-sdk-${VERSION}"
    SHA512 580a25dad78b89b6ca5913b1023a06a0442c011fdbeb409e84e9bad20d869a4686088528f1f6f222bbcf78cb6365af09de2b6b9c88043b6b3a9e6928f1f77d62
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
