vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org
    OUT_SOURCE_PATH SOURCE_PATH
    REPO uchardet/uchardet
    REF "v${VERSION}"
    SHA512 8d7a0abe1fcf7e92f9e264252eefa5810176603e3d3d825a23c3f5d23cd4f7cce9a0a9539e84bd70af5b66688394e48af00a00ce759a5a3d69b650f92351b6f2
    HEAD_REF master
    PATCHES
        fix-uwp-build.patch
        fix-config-error.patch
)


vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tool BUILD_BINARY
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS_DEBUG
        -DBUILD_BINARY=OFF
    OPTIONS_RELEASE
        ${FEATURE_OPTIONS}
    OPTIONS
        -DBUILD_STATIC=${BUILD_STATIC}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/uchardet)

vcpkg_copy_pdbs()

vcpkg_fixup_pkgconfig()

if(tool IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES uchardet AUTO_CLEAN)
endif()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/share/man"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
