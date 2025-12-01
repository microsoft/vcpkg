vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO simdutf/simdutf
    REF "v${VERSION}"
    SHA512 0d1d15f0030b002a6cb865b8876f252d9ad1657b7396248902f3adbe23023ac705a40c57e3f1895c3f66fbab6d490c69b545baecdd6ea7a085b0e5c694e38a42
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
    "tools" SIMDUTF_TOOLS
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
        -DSIMDUTF_TESTS=OFF
        -DSIMDUTF_BENCHMARKS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})
vcpkg_fixup_pkgconfig()
if ("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES fastbase64 sutf AUTO_CLEAN)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE-APACHE")
