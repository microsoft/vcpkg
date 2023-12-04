vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/Vulkan-ExtensionLayer
    REF "vulkan-sdk-${VERSION}"
    SHA512 3bcfb2e77e40817b4e6bca6541d57853cae6af87e610ff408e88544d92f680c83b569c07dd5c81129624e3224e00c5f94a30ff44ce11a611bfe7cf64dc3da2bf
    HEAD_REF main
)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    -DBUILD_TESTS:BOOL=OFF
)
vcpkg_cmake_install()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

set(VCPKG_POLICY_DLLS_WITHOUT_LIBS enabled)
set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

