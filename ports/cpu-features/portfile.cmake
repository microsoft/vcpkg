vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/cpu_features
    REF a8397ba4591237c17d18e4acc091f5f3ebe7391e # 0.6.0
    SHA512 71a583e8190699d6df3dfa2857886089265cdfbcb916d9828a3611a1d6d23487464d6448b900b49637f015dd7d4e18bb206e0249af0932928f8ced13a081d42b
    HEAD_REF master
    PATCHES
        make_list_cpu_features_optional.patch
        windows-x86-fix.patch
)

# If feature "tools" is not specified, disable building/exporting executable targets.
# This is necessary so that downstream find_package(CpuFeatures) does not fail.
vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tools BUILD_EXECUTABLE
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME "CpuFeatures" CONFIG_PATH "lib/cmake/CpuFeatures")

if("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES "list_cpu_features" AUTO_CLEAN)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
