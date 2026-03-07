set(VCPKG_BUILD_TYPE release) # Only headers and tools

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO huira-render/huira
    REF "v${VERSION}"
    SHA512 acbe259332e59eadf84f588a8e9bc5c5c717469fec2be5098ffeecaa6f5c2557dc3c0ad2d968c2803e289b75714fc7a87021b6960be5b321ce1dfd9f029db3fe
    HEAD_REF main
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tools HUIRA_TOOLS
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
