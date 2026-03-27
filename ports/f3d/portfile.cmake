vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO f3d-app/f3d
    REF v${VERSION}
    SHA512 43d341427df2de42df87518c76fa3bea35a3617938bf67dd2c27830ec48cc41e1b5c3b269d0dda88ffddb5f178acc3244fc0026ec7f68259eb2850969efbbb3c
    HEAD_REF master
    PATCHES
        fix-install.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        application F3D_BUILD_APPLICATION
        # optional modules
        exr         F3D_MODULE_EXR
        # optional plugins
        alembic     F3D_PLUGIN_BUILD_ALEMBIC
        assimp      F3D_PLUGIN_BUILD_ASSIMP
        draco       F3D_PLUGIN_BUILD_DRACO
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DF3D_MACOS_BUNDLE=OFF
        -DF3D_WINDOWS_BUILD_SHELL_THUMBNAILS_EXTENSION=OFF
    MAYBE_UNUSED_VARIABLES
        F3D_MACOS_BUNDLE
        F3D_WINDOWS_BUILD_SHELL_THUMBNAILS_EXTENSION
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/f3d)

# If the application feature is enabled, install it as a tool
if("application" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES f3d AUTO_CLEAN)
endif()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
