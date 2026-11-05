# cli/2.7.2 has no dllexport annotations, so shared build yields a DLL without exports.
if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CLIUtils/CLI11
    REF "v${VERSION}"
    SHA512 437cd9d704c1b0de0516bdc8cb115befb2e7170417375a64845a2bc2385fa07948c4af724ec615d27fbc102dbe13a7117f33873d6776fe9b17f293d42fe64dd9
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
