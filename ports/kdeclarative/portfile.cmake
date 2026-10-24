vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/kdeclarative
    REF "v${VERSION}"
    SHA512 39af75d08636d99053ba832e8e2d4b576777ea93330adb713523e1202abf2869a24d5c055b80477a5cb5cb4d46fcb1f4d18ac6288789fc4fea70ab4a76ccdcd2
    HEAD_REF master
)

# Prevent KDEClangFormat from writing to source effectively blocking parallel configure
file(WRITE "${SOURCE_PATH}/.clang-format" "DisableFormat: true\nSortIncludes: false\n")

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    INVERTED_FEATURES
        translations KF_SKIP_PO_PROCESSING
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_Qt6Tools=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Qt6ToolsTools=ON
        -DKDE_INSTALL_QMLDIR=qml
        ${FEATURE_OPTIONS}
    # Used by ecm_find_qmlmodule(org.kde.ki18n)
    OPTIONS_RELEASE
        "-DCMAKE_INCLUDE_PATH=${CURRENT_INSTALLED_DIR}/qml/org/kde/ki18n"
    OPTIONS_DEBUG
        "-DCMAKE_INCLUDE_PATH=${CURRENT_INSTALLED_DIR}/debug/qml/org/kde/ki18n"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME kf6declarative CONFIG_PATH lib/cmake/KF6Declarative)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

file(GLOB LICENSE_FILES "${SOURCE_PATH}/LICENSES/*")
vcpkg_install_copyright(FILE_LIST ${LICENSE_FILES})
