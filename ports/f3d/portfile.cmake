vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO f3d-app/f3d
    REF v${VERSION}
    SHA512 da302baff8294af87032d238552f46dbd6ebce04dce2a8ec4711c79398f01d38641b2a8e7da4ab3261c555c6eaf84b73c91e3b100a3a85ef1e1d24b3a654d79e
    HEAD_REF master
    PATCHES
        fix-install.patch
)
file(GLOB external_sources "${SOURCE_PATH}/external/*")
list(REMOVE_ITEM external_sources "${SOURCE_PATH}/external/CMakeLists.txt")
file(REMOVE_RECURSE ${external_sources})

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        application F3D_BUILD_APPLICATION
        application F3D_WINDOWS_BUILD_CONSOLE_APPLICATION
        application F3D_USE_EXTERNAL_CXXOPTS        # avoid REQUIRED
        application F3D_USE_EXTERNAL_DMON           # avoid REQUIRED
        application F3D_USE_EXTERNAL_NLOHMANN_JSON  # avoid REQUIRED
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
        -DF3D_USE_EXTERNAL_IMGUI=ON
        -DF3D_WINDOWS_BUILD_SHELL_THUMBNAILS_EXTENSION=OFF
    OPTIONS_DEBUG
        -DF3D_BUILD_APPLICATION=OFF
        -DF3D_WINDOWS_BUILD_CONSOLE_APPLICATION=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/f3d)

# If the application feature is enabled, install it as a tool
if("application" IN_LIST FEATURES)
    set(tools f3d)
    if(VCPKG_TARGET_IS_WINDOWS)
        list(APPEND tools f3d-console)
    endif()
    vcpkg_copy_tools(TOOL_NAMES ${tools} AUTO_CLEAN)
endif()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
