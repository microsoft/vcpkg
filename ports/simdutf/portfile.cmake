vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO simdutf/simdutf
    REF "v${VERSION}"
    SHA512 3639f51386f14178fa6681d5c305fb21acb57a45c3dc95c78bfc27e796f714ea8f1d1bba84fd1027f7763e4fe53735bdfb68cd04ae8c2e34fa512dd1bc4e7318
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
