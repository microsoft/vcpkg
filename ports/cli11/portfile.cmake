vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CLIUtils/CLI11
    REF "v${VERSION}"
    SHA512 28ff846ca0b736c784d1660b4d1470f34f55fed650c80fb6a2ec26519eaacbb80dd1aa951a4517097579f4aa0cf9527a13f3359744e589e31f852d1bea0ecfc8
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
        -DCMAKE_CXX_STANDARD=17
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH share/cmake/CLI11)
vcpkg_fixup_pkgconfig()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/CLI/CLI.hpp" "#pragma once" "#pragma once\n#ifndef CLI11_COMPILE\n#define CLI11_COMPILE\n#endif")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
