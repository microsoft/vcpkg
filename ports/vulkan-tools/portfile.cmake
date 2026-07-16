vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/Vulkan-Tools
    REF "vulkan-sdk-${VERSION}"
    SHA512 016bceae9d2caa276a6d7465f53e8a608e94c2c029f5be36c8706f23a0196c1e7bfff60a057c8cd3d39b7c143ece08977a6459500c5da0d9dd29b2fa2cab1f2a
    HEAD_REF main
)

if(NOT VCPKG_TARGET_IS_ANDROID)
    set(VCPKG_BUILD_TYPE release) # only builds tools
endif()

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    -DBUILD_TESTS:BOOL=OFF
)
vcpkg_cmake_install()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")

set(tools vulkaninfo)
if(NOT VCPKG_TARGET_IS_ANDROID)
    list(APPEND tools vkcube vkcubepp)
endif()
vcpkg_copy_tools(TOOL_NAMES ${tools} AUTO_CLEAN)

set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

if(NOT VCPKG_TARGET_IS_ANDROID)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
endif()
