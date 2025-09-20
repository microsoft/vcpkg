vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO luau-lang/luau
    REF ${VERSION}
    SHA512 3738e44402ed03e4ea2ec5306685625dd16f789b03f8e003e35b647470829e466b7884a43cde40501b85353ad2e851e8ff062e717655c327d53f0daba0efa7d5
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

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
