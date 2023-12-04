vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/Vulkan-Profiles
    REF "vulkan-sdk-${VERSION}"
    SHA512 720bd13074df5ff6a8db53b477e81709341ac8cb62fe0a7c685c6ea3303bd20549372efbf0934ebae390411452a87ddddac7c0e2048352c3a52ef001aad49358
    HEAD_REF main
    PATCHES jsoncpp.patch
)

x_vcpkg_get_python_packages(PYTHON_VERSION "3" PACKAGES jsonschema OUT_PYTHON_VAR PYTHON3)
get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
vcpkg_add_to_path("${PYTHON3_DIR}")

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  DISABLE_PARALLEL_CONFIGURE
  OPTIONS
    -DBUILD_TESTS:BOOL=OFF
    -DVULKAN_HEADERS_INSTALL_DIR=${CURRENT_INSTALLED_DIR}
)
vcpkg_cmake_install()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")

file(REMOVE_RECURSE 
  "${CURRENT_PACKAGES_DIR}/debug/include"
  "${CURRENT_PACKAGES_DIR}/debug/share"
)

set(VCPKG_POLICY_DLLS_WITHOUT_LIBS enabled)