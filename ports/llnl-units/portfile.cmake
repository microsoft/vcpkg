vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO LLNL/units
    REF "v${VERSION}"
    SHA512 4b847cbf0d09ad39185058f95286dd4db95a123b399af707440cc22b5d8d7efd67741e610170e14aa744935a9ec9b58aa782ffd32fbf7366df473e40f2c318cd
    HEAD_REF main
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tools UNITS_BUILD_CONVERTER_APP
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DUNITS_CMAKE_PROJECT_NAME=LLNL-UNITS
        -DUNITS_ENABLE_TESTS=OFF
        -DUNITS_BUILD_FUZZ_TARGETS=OFF
        -DLLNL-UNITS_ENABLE_ERROR_ON_WARNINGS=OFF
        -DLLNL-UNITS_ENABLE_EXTRA_COMPILER_WARNINGS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME llnl-units CONFIG_PATH lib/cmake/llnl-units)

if("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES units_convert AUTO_CLEAN)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
