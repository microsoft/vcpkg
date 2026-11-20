vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/Vulkan-Tools
    REF "vulkan-sdk-${VERSION}"
    SHA512 0a1b918e58da6b3453696618210ce08bedcb5c6b1340d700bd6368c0c45c3a65bb7beaa92a78cb76d640bee7ce67065cc19318b5da3fafe30b1dcb2837ea9923
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
