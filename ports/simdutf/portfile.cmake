vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO simdutf/simdutf
    REF "v${VERSION}"
    SHA512 920737f4d2ad5dd4802098b7ad48c47cc477fbeb63ed7b847edb6c71e95b83a54a6db0c38614ad99b403241dd561ff0f4bbc81f10d35e7432aac4280aec370c7
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
