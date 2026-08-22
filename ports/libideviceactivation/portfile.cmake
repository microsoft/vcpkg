vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libimobiledevice/libideviceactivation
    REF 067c439e0b18d6f1c8a37dde791f9d91191a922e # commits on 2023-05-01
    SHA512 0afd74720abc6a1e47e035243879d291444b27667ce0a1908a4e66fea92185ff002e5390a1911ae95dc05d0bb0518a0043c77b531edcc5ac8b59c913aea9d487
    HEAD_REF master
    PATCHES
        001_fix_static_build.patch
        002_fix_api.patch
        003_fix_tools_msvc.patch
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
    vcpkg_copy_tools(TOOL_NAMES ideviceactivation AUTO_CLEAN)
endif()

file(READ "${CURRENT_PACKAGES_DIR}/share/unofficial-${PORT}/unofficial-${PORT}-config.cmake" cmake_config)
file(WRITE "${CURRENT_PACKAGES_DIR}/share/unofficial-${PORT}/unofficial-${PORT}-config.cmake"
"include(CMakeFindDependencyMacro)
find_dependency(unofficial-libplist CONFIG)
find_dependency(unofficial-libimobiledevice CONFIG)
find_dependency(CURL CONFIG)
find_dependency(LibXml2 CONFIG)
${cmake_config}
")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
