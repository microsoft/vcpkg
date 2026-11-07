vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nonstd-lite/string-view-lite
    REF "v${VERSION}"
    SHA512 6e8cb47ce95ba5fb8bc5396c11a65c70beabbeaedf15ebbfee8c347ed317056497737f114af595d6b0242228326e2948bcf7de611170a3e993a0f529d0a7e626
)

set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSTRING_VIEW_LITE_OPT_BUILD_TESTS=OFF
        -DSTRING_VIEW_LITE_OPT_BUILD_EXAMPLES=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
