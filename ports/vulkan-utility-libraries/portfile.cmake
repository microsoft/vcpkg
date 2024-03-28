vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/Vulkan-Utility-Libraries
    REF "v${VERSION}"
    SHA512 572064a1cc86c4ae588e62e2c96cdd323475514ff7cf94d7bdb27a7cd41465de6dc961fca159bd581a2deb1f313214ce5d77dca8ade54f3b829f4188bca06d91
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
