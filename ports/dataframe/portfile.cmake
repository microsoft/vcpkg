vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO hosseinmoein/DataFrame
    REF "${VERSION}"
    SHA512 0586c114091dcc030d25a16dfe5f8bc9eeaedd1f8d7be6ceeb14538fd848fab45515367de0bb095b8a91b4570111a76c37ffe1cb406b136afef2dcf0fd977ac7
    HEAD_REF master
)
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DHMDF_TESTING:BOOL=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/DataFrame)

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/License")
