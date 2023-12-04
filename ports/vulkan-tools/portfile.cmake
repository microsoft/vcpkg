vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/Vulkan-Tools
    REF "vulkan-sdk-${VERSION}"
    SHA512 9359e9528bfe507870bd83f9e8860b3d82555c0d8a6a19284f150dd2288b204f2c9dc9b3f62be4efbbb5e2983862459b2131de126a603cc5531ef8df72f4458f
    HEAD_REF main
)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    -DBUILD_TESTS:BOOL=OFF
)
vcpkg_cmake_install()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")

vcpkg_copy_tools(TOOL_NAMES vkcube vkcubepp vulkaninfo AUTO_CLEAN )

set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
