set(VCPKG_BUILD_TYPE release)  # header-only

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nonstd-lite/scope-lite
    REF "v${VERSION}"
    SHA512 e159d7e31e0b9690b38ad9ee22368e9b230dd89419ac4198b0f64923b42acce24c1a6ebf3fcc4e7fed8a3942bb9b2d666d8098ae1a5f35f6f099343b22f646fe
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSCOPE_LITE_OPT_BUILD_TESTS=OFF
        -DSCOPE_LITE_OPT_BUILD_EXAMPLES=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME scope-lite
    CONFIG_PATH lib/cmake/scope-lite
)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/lib"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
