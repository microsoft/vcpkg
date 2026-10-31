vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xyo-financial/sdk-cpp
    REF "v${VERSION}"
    SHA512 6277af5187b9453efef4fe873f6a5e99787e6d2a467aec50cab47372e9cf4c4c9484a8693426d2564985f7d3762b1b53e32084b396d87c9549257cb54b0e9b01
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DXYO_BUILD_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME XYOSDK CONFIG_PATH lib/cmake/XYOSDK)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
