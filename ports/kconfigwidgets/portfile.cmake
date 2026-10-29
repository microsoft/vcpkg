vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/kconfigwidgets
    REF "v${VERSION}"
    SHA512 16adfa15ed1574c48ff7259630205c308e3560e3479536935f57ec542b1b699214f9af86424011c1e92139ce9c9f0e8f665abc1c52e5f2e269f64981d8371d63
    HEAD_REF master
)

# Prevent KDEClangFormat from writing to source effectively blocking parallel configure
file(WRITE "${SOURCE_PATH}/.clang-format" "DisableFormat: true\nSortIncludes: false\n")

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        designerplugin BUILD_DESIGNERPLUGIN
    INVERTED_FEATURES
        translations   KF_SKIP_PO_PROCESSING
)

if(VCPKG_TARGET_IS_LINUX)
    list(APPEND FEATURE_OPTIONS -DUSE_DBUS=ON)
else()
    list(APPEND FEATURE_OPTIONS -DUSE_DBUS=OFF)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_Qt6Tools=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Qt6ToolsTools=ON
        -DKDE_INSTALL_PLUGINDIR=plugins
        -DKDE_INSTALL_QTPLUGINDIR=plugins
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME kf6configwidgets CONFIG_PATH lib/cmake/KF6ConfigWidgets)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

file(GLOB LICENSE_FILES "${SOURCE_PATH}/LICENSES/*")
vcpkg_install_copyright(FILE_LIST ${LICENSE_FILES})
