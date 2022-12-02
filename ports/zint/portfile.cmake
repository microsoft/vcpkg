vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO zint/zint
    REF 2.11.1
    SHA512 21dbe5dc99b46f79ac1a819fd4e20de22bee8928da5f6b4883a0767243a8633c65f559ac60328dcd70b75a90438c0047c31c6ace1a10750a2579042f54aa801b
    HEAD_REF master
    PATCHES
        0001-fix-static-lib.patch
        0002-install-export.patch
        0003-fix-parallel-configure.patch
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        png ZINT_USE_PNG
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DZINT_USE_QT=OFF
        -DZINT_TEST=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-zint)
vcpkg_copy_pdbs()

vcpkg_copy_tools(TOOL_NAMES zint AUTO_CLEAN)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/man")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/apps")

configure_file(
    "${CMAKE_CURRENT_LIST_DIR}/unofficial-zint-config.cmake.in"
    "${CURRENT_PACKAGES_DIR}/share/unofficial-zint/unofficial-zint-config.cmake"
    @ONLY
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
