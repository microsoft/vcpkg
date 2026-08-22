vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/cpu_features
    REF "v${VERSION}"
    SHA512 6e3f484a6cd676d1c0b5571642397289dae3979085140d1324c10c5a971b34e9e46293217cbdf62f02a4b0632fb631fefeee876d579bafeeec1a0b75ba466809
    HEAD_REF master
    PATCHES
        0001-ndk-compat-export-include-dirs.patch
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
