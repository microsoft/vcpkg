vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/Vulkan-Profiles
    REF "vulkan-sdk-${VERSION}"
    SHA512 720bd13074df5ff6a8db53b477e81709341ac8cb62fe0a7c685c6ea3303bd20549372efbf0934ebae390411452a87ddddac7c0e2048352c3a52ef001aad49358
    HEAD_REF main
    PATCHES jsoncpp.patch
)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  DISABLE_PARALLEL_CONFIGURE
  OPTIONS
    -DBUILD_TESTS:BOOL=OFF
    -DVULKAN_HEADERS_INSTALL_DIR=${CURRENT_INSTALLED_DIR}
)
vcpkg_cmake_install()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
