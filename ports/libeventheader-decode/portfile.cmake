vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO "microsoft/LinuxTracepoints"
    REF "v${VERSION}"
    SHA512 baf27c967b2fa1fb8e8684951fd8e12e40fe9c23f5052a2d77c63eceab6ddfc112537422b97c37cfb0e479361fa8aedea6d8d7edfae91810f1ed696060fcb822
    HEAD_REF main)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tools  BUILD_TOOLS
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/libeventheader-decode-cpp"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DBUILD_SAMPLES=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

if (BUILD_TOOLS)
    vcpkg_copy_tools(
        TOOL_NAMES perf-decode
        AUTO_CLEAN)
endif()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME eventheader-decode
    CONFIG_PATH lib/cmake/eventheader-decode)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
