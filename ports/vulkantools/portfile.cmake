vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO LunarG/VulkanTools
    REF "vulkan-sdk-${VERSION}"
    SHA512 83be64eccb2841de4ae67f3936b6dd4433cdbd2b604329914a8bc43c1f7fc6dd2dba0eaf2f9527b231c6d54d3d390d79defc6de228baff5cba1add8c5ad6d9cd
    HEAD_REF main
)

vcpkg_replace_string("${SOURCE_PATH}/via/CMakeLists.txt" "jsoncpp_static" "JsonCpp::JsonCpp")

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    -DVULKAN_HEADERS_INSTALL_DIR=${CURRENT_INSTALLED_DIR}
    -DBUILD_TESTS:BOOL=OFF
  OPTIONS_RELEASE
    -DVULKAN_LOADER_INSTALL_DIR=${CURRENT_INSTALLED_DIR}
  OPTIONS_DEBUG
    -DVULKAN_LOADER_INSTALL_DIR=${CURRENT_INSTALLED_DIR}/debug

)
vcpkg_cmake_install()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")

vcpkg_copy_tools(TOOL_NAMES vkvia vkconfig AUTO_CLEAN )

set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

