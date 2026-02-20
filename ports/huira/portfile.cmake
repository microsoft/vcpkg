set(VCPKG_BUILD_TYPE release) # Only headers and tools

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO huira-render/huira
    REF "v${VERSION}"
    SHA512 7f46d1c514a4a7ba5981dd2224ff4b01b3dc8f30903cf91f3bde25135d338dd7ac375d68eb75502d26264f7c6e54195c6126487cfc51c0a7c87f7c53d49df30f
    HEAD_REF main
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tools HUIRA_APPS
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DHUIRA_TESTS=OFF
)

vcpkg_cmake_install()

if("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES huira AUTO_CLEAN)
endif()

# Fix up the installed CMake config so that paths are relocatable.
vcpkg_cmake_config_fixup(
    PACKAGE_NAME huira
    CONFIG_PATH lib/cmake/huira
)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/bin"
    "${CURRENT_PACKAGES_DIR}/debug/bin"
    "${CURRENT_PACKAGES_DIR}/lib"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
