vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO martinmoene/expected-lite
    REF "v${VERSION}"
    SHA512 c12d9d30dc137614ea0934dae405e4d16934aac0081987458347d7ecd30d915028ed2dbd3c2214ffcf73f0c0a2600d6e5f2fbd0aa66b4763f5a308d5c3e18611
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DEXPECTED_LITE_OPT_BUILD_TESTS=OFF
        -DEXPECTED_LITE_OPT_BUILD_EXAMPLES=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    CONFIG_PATH lib/cmake/${PORT}
)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug"
    "${CURRENT_PACKAGES_DIR}/lib"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
