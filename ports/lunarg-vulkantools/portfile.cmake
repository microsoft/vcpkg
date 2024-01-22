vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO LunarG/VulkanTools
    REF "vulkan-sdk-${VERSION}"
    SHA512 83be64eccb2841de4ae67f3936b6dd4433cdbd2b604329914a8bc43c1f7fc6dd2dba0eaf2f9527b231c6d54d3d390d79defc6de228baff5cba1add8c5ad6d9cd
    HEAD_REF main
)

vcpkg_replace_string("${SOURCE_PATH}/via/CMakeLists.txt" "jsoncpp_static" "JsonCpp::JsonCpp")

x_vcpkg_get_python_packages(PYTHON_VERSION "3" PACKAGES jsonschema OUT_PYTHON_VAR PYTHON3)
get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
vcpkg_add_to_path("${PYTHON3_DIR}")

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

if(VCPKG_TARGET_IS_WINDOWS)
  file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
endif()

set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

