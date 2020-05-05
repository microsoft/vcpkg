include(vcpkg_common_functions)

# On Windows, we can get a cpuinfo.dll, but it exports no symbols.
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_download_distfile(
    pull_22_patch_file
    URLS "https://github.com/pytorch/cpuinfo/compare/d5e37adf1406cf899d7d9ec1d317c47506ccb970...868bd113ed496a01cd030ab4d5b8853561f919a3.diff"
    FILENAME "cpuinfo-pull-22-868bd11.patch"
    SHA512 6971707e71613ca07fe0d18cb9c36cd5161177fc9ad3eb9e66f17a694559f3a95ccdad8f50e9342507a7978bd454f66e47c8a94db9077267ca302535b7cc3b59
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pytorch/cpuinfo
    REF d5e37adf1406cf899d7d9ec1d317c47506ccb970
    SHA512 ecd2115340fa82a67db7889ce286c3070d5ab9c30b02372b08aac893e90ccebc65c6b3e66aa02a9ae9c57892d2d8c3b77cb836e5fc3b88df2c75d33e574d90d2
    HEAD_REF master
    PATCHES
        ${pull_22_patch_file}
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    tools CPUINFO_BUILD_TOOLS
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG
        -DCPUINFO_BUILD_TOOLS=OFF
    OPTIONS_RELEASE
        ${FEATURE_OPTIONS}
    OPTIONS
        -DCPUINFO_BUILD_UNIT_TESTS=OFF
        -DCPUINFO_BUILD_MOCK_TESTS=OFF
        -DCPUINFO_BUILD_BENCHMARKS=OFF
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

if(tools IN_LIST FEATURES)
    vcpkg_copy_tools(
        TOOL_NAMES cache-info cpuid-dump cpu-info isa-info
        AUTO_CLEAN
    )
endif()

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)

# CMake integration test
vcpkg_test_cmake(PACKAGE_NAME ${PORT})
