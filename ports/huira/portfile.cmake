set(VCPKG_BUILD_TYPE release) # Only headers and tools

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO huira-render/huira
    REF "v${VERSION}"
    SHA512 62880784c356197ab631715095f6341119fe4bea039aaa1f4004daf2999af548d78f207af0f49209a69c78416b7dc6574a5d48d8f1f2400f7fe6ca038e7e01d5
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
        -DHUIRA_NATIVE_ARCH=OFF
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
