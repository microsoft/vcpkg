vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/Vulkan-Headers
    REF d732b2de303ce505169011d438178191136bfb00
    SHA512 425d393dec95902af46f182b3d8d5d279efefddc9cbce05c2b3e4f1706fa05ff74db0a3db2adc370bf6ac25c152c66d9a96feaac8a427acdc46b1d27e69c2608
    HEAD_REF v1.3.243
)

set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)
vcpkg_cmake_install()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
