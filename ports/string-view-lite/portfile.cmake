vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO martinmoene/string-view-lite
    REF v1.7.0
    SHA512 9dd8d2ad838275b1d5418520acf0f215dc586ff40f2dac7a2e4fd845aae5eb3663ce81bc6117df50b0a68f2b8152f3d3ccb0d611728af47bc1b11286328125b5
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
