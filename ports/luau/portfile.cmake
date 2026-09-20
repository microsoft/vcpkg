vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO luau-lang/luau
    REF "${VERSION}"
    SHA512 8c9cf7baba49153cd1b00f528dcd9cc1130e56c5235345416485090e79f6b66d505038fa730c206afe0e7e480fe00cd49c80bc91c03baeb499ec01e1af94db1a
    HEAD_REF master
    PATCHES
        cmake-config-export.patch
        fix-unittest.patch
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tool LUAU_BUILD_CLI
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DLUAU_BUILD_TESTS=OFF
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

vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/LICENSE.txt"
        "${SOURCE_PATH}/extern/isocline/LICENSE"
)
