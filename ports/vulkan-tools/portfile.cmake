vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/Vulkan-Tools
    REF "vulkan-sdk-${VERSION}"
    SHA512 163b6348064b807ae22ed14945d558fdb18789af22f4bca4dcd017699eef41bae4ca86114297c02f6caed7206882676fca9bc58b9acdae2db46356d266af307a
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
