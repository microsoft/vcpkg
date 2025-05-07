vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/cpu_features
    REF "v${VERSION}"
    SHA512 8b7415322c82edc1e9a226961f9a2a8302b8262d99a8bb3f16211784ea23fafa26886e7351e3b6e183737257c462ab1714dc7f34784574209436f4e5ae43ecef
    HEAD_REF master
)

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

if(VCPKG_TARGET_IS_ANDROID)
    vcpkg_cmake_config_fixup(PACKAGE_NAME "CpuFeatures" CONFIG_PATH "lib/cmake/CpuFeatures" DO_NOT_DELETE_PARENT_CONFIG_PATH)
    vcpkg_cmake_config_fixup(PACKAGE_NAME "CpuFeaturesNdkCompat" CONFIG_PATH "lib/cmake/CpuFeaturesNdkCompat")
else()
    vcpkg_cmake_config_fixup(PACKAGE_NAME "CpuFeatures" CONFIG_PATH "lib/cmake/CpuFeatures")
endif()

if("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES "list_cpu_features" AUTO_CLEAN)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
if(VCPKG_TARGET_IS_ANDROID)
    file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage_android" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME "usage")
else()
    file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
endif()
