vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/Vulkan-Tools
    REF "vulkan-sdk-${VERSION}"
    SHA512 2d2afbcb06bb1ee08ffb3cbe133b531fe6341e90fa0dca4d5459dbdedf201521e798226768a7e307f8b6c08b388114a34a9a581a294f6226ca7a2fcd6f63f813
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
