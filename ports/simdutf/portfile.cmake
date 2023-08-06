vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO simdutf/simdutf
    REF v3.2.15
    SHA512 b8d8296569910e08a6cbbdf6d97bbaacca7ef24a568fa6dd2c87fe1361af86640619e49160b9577ae0702f4876634ba3f4381287ebb3e5e21d8eda3e9ece104e
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
    "tools" SIMDUTF_TOOLS
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS "-DSIMDUTF_TESTS=OFF -DSIMDUTF_BENCHMARKS=OFF ${FEATURE_OPTIONS}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})
if ("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES sutf AUTO_CLEAN)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE-APACHE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
