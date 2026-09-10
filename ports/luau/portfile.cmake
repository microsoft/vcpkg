vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO luau-lang/luau
    REF "${VERSION}"
    SHA512 68d422d01047143aa51eb347435a0d7db0d840f175c5ae2ec6602339110e9c702e8597ecad7035c12b1f7edc1feb084b99426d537199f780515acc501f4a2eeb
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
