vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/cpu_features
    REF v0.7.0
    SHA512 e602c88c4a104d69dff0297a4c4f8e26d02d548fc35ce2616429ff8280f2a37e9eaa99451a38b7c302907352cf15bdf8c09c2e0e52b09bf4cd3b7e2b21f8ddb0
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
        -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME "CpuFeatures" CONFIG_PATH "lib/cmake/CpuFeatures")

if("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES "list_cpu_features" AUTO_CLEAN)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
