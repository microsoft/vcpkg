vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/Vulkan-ValidationLayers
    REF "vulkan-sdk-${VERSION}"
    SHA512 74282cede73f67ee39ab78b99cd53f78ac0427ec6ca897ec41eb28b0e2d1106006d688bfbfdb2f0924b84149d516d42b1abe3680cdc6019c66457451f19b44dd
    HEAD_REF main
)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    -DBUILD_TESTS:BOOL=OFF
)
vcpkg_cmake_install()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")

set(VCPKG_POLICY_DLLS_WITHOUT_LIBS enabled)
