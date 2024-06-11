vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CLIUtils/CLI11
    REF "v${VERSION}"
    SHA512 fdb61c430f5b99a9495fda7f94bfc8d0fb5360c99beeccbcb3b8918713579aac97fa0dcbce296065d9043f141a538c505919c9810fd1d192661e8b48b6a2637a
    HEAD_REF main
    PATCHES
        revert-1012-pkgconfig.diff
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCLI11_BUILD_EXAMPLES=OFF
        -DCLI11_BUILD_DOCS=OFF
        -DCLI11_BUILD_TESTS=OFF
        -DCLI11_PRECOMPILED=ON
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH share/cmake/CLI11)
vcpkg_fixup_pkgconfig()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/CLI/CLI.hpp" "#pragma once" "#pragma once\n#ifndef CLI11_COMPILE\n#define CLI11_COMPILE\n#endif")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
