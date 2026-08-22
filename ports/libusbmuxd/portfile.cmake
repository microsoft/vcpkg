vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libimobiledevice/libusbmuxd
    REF 8d30a559cf0585625d9d05dc8ce0dd495b1de4f4 # commits on 2023-06-21
    SHA512 ace920d13908c12afcc9182776a668f6876b2f037b21a151c1dca897aa24bc24cb41898471cd258487963772963753457be5efba2657571cf2c07c8225b68a5f
    HEAD_REF master
    PATCHES
        001_fix_win32_defs.patch
        002_fix_struct_pack.patch
        003_fix_msvc.patch
        004_fix_api.patch
        005_fix_tools_msvc.patch
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/exports.def" DESTINATION "${SOURCE_PATH}")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tools BUILD_TOOLS
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-${PORT})
vcpkg_fixup_pkgconfig()
if("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES inetcat iproxy AUTO_CLEAN)
endif()

file(READ "${CURRENT_PACKAGES_DIR}/share/unofficial-${PORT}/unofficial-${PORT}-config.cmake" cmake_config)
file(WRITE "${CURRENT_PACKAGES_DIR}/share/unofficial-${PORT}/unofficial-${PORT}-config.cmake"
"include(CMakeFindDependencyMacro)
find_dependency(unofficial-libplist CONFIG)
find_dependency(unofficial-libimobiledevice-glue CONFIG)
${cmake_config}
")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
