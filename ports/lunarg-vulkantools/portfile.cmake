vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO LunarG/VulkanTools
    REF "vulkan-sdk-${VERSION}"
    SHA512 2d1f5d91aa79b206640e65bba2dadfe881524e9a5e1694df5092e6d59d00f06cd981bd026c0c12528f6b243da7564be98211ce6f6538bd1fd51698f91aa24d47
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

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")

vcpkg_copy_tools(TOOL_NAMES vkvia vkconfig AUTO_CLEAN )

set(VCPKG_POLICY_DLLS_WITHOUT_LIBS enabled)
set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
