vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO simdutf/simdutf
    REF "v${VERSION}"
    SHA512 cba5850d7182305da9f4e4f6029c3f1b46a1b407d54ae2661c805e734490cb435ad2a641e44bcfcf05726f5d927b0ac37d510b858e61c352118e0e63c323d980
    HEAD_REF master
    PATCHES
        bindir.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
    "tools" SIMDUTF_TOOLS
    "tools" SIMDUTF_ICONV
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSIMDUTF_TESTS=OFF
        -DSIMDUTF_BENCHMARKS=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})
vcpkg_fixup_pkgconfig()
if ("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES fastbase64 sutf AUTO_CLEAN)
endif()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/debug/tools"
)

set(COPYRIGHT_FILES
    "${SOURCE_PATH}/LICENSE-APACHE"
    "${SOURCE_PATH}/LICENSE-MIT"
    "${SOURCE_PATH}/include/simdutf/internal/isadetection.h"
)
if("tools" IN_LIST FEATURES AND VCPKG_TARGET_IS_WINDOWS)
    list(APPEND COPYRIGHT_FILES "${CURRENT_INSTALLED_DIR}/share/libiconv/copyright")
endif()
vcpkg_install_copyright(FILE_LIST ${COPYRIGHT_FILES})
