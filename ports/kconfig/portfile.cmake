vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/kconfig
    REF "v${VERSION}"
    SHA512 efcdde76afc47fe73964bfcedd73576c6371592759c5c71c54d4ca036a0bb0641303057c3a89b47db1d74a22cbeda4f871d197cf0d1a79bce090b198e5a92da1
    HEAD_REF master
)

# Prevent KDEClangFormat from writing to source effectively blocking parallel configure
file(WRITE "${SOURCE_PATH}/.clang-format" "DisableFormat: true\nSortIncludes: false\n")

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        qml KCONFIG_USE_QML
    INVERTED_FEATURES
        translations KF_SKIP_PO_PROCESSING
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_Qt6Tools=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Qt6ToolsTools=ON
        -DKDE_INSTALL_QMLDIR=Qt6/qml
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME kf6config CONFIG_PATH lib/cmake/KF6Config)
vcpkg_copy_pdbs()

vcpkg_copy_tools(
    TOOL_NAMES kreadconfig6 kwriteconfig6
    AUTO_CLEAN
)

vcpkg_copy_tools(
    TOOL_NAMES kconf_update kconfig_compiler_kf6
    AUTO_CLEAN
)

file(APPEND "${CURRENT_PACKAGES_DIR}/tools/${PORT}/qt.conf" "Data = ../../share")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(GLOB LICENSE_FILES "${SOURCE_PATH}/LICENSES/*")
vcpkg_install_copyright(FILE_LIST ${LICENSE_FILES})
