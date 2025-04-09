vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO luau-lang/luau
    REF ${VERSION}
    SHA512 4076d108555eb003a494cd2c0d37122a5b70719891784cf8ef499e5af1234de7386d3c717c836edf07b017c1f857826437e3e9c22adec096a9f0e7ddab87caad
    HEAD_REF master
    PATCHES
        cmake-config-export.patch
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tool LUAU_BUILD_CLI
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DVERSION=${VERSION}
        ${FEATURE_OPTIONS}
    OPTIONS_DEBUG
        -DLUAU_BUILD_CLI=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME "unofficial-luau")

if("tool" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES luau AUTO_CLEAN)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
