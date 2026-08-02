set(VCPKG_BUILD_TYPE release) # Only headers and tools

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO huira-render/huira
    REF "v${VERSION}"
    SHA512 ed15d0a35c799c2f3b2f0c8eed8f26597e6dab5cb8a5e57d2e393c35139ecde7eef0a721c120b6018604db5c18052b245caf96f56f2d538d290087840b56223a
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
        -DCMAKE_DISABLE_FIND_PACKAGE_PkgConfig=ON
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/huira)

if("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES huira AUTO_CLEAN)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
