vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CLIUtils/CLI11
    REF "v${VERSION}"
    SHA512 895fb61e4c9974ee8e8d4681fb880a10126a412f24bb147d558d465d78fe784a044c5443edf1ce20fc9936901073073d795b034e0c02bdb3c8aa74c9d6ac811c
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
