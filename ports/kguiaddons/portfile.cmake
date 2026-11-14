vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/kguiaddons
    REF "v${VERSION}"
    SHA512 24aee1d8a8c04340db8342a176a625e2c6c01963355565af274e3e560c6a540f614387ccedd07a9e1d39aaa80dcc409ec688ceef992e7202de25e805e1e0dee5
    HEAD_REF master
)

# Prevent KDEClangFormat from writing to source effectively blocking parallel configure
file(WRITE "${SOURCE_PATH}/.clang-format" "DisableFormat: true\nSortIncludes: false\n")

if(NOT "qml" IN_LIST FEATURES)
  list(APPEND FEATURE_OPTIONS "-DCMAKE_DISABLE_FIND_PACKAGE_Qt6Qml=ON")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_Qt6ToolsTools=ON
        -DBUILD_PYTHON_BINDINGS=OFF
        -DKDE_INSTALL_QMLDIR=Qt6/qml
        -DCMAKE_DISABLE_FIND_PACKAGE_Qt6Tools=ON
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
    PACKAGE_NAME kf6guiaddons
    CONFIG_PATH lib/cmake/KF6GuiAddons
)
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig(SKIP_CHECK)

vcpkg_copy_tools(
    TOOL_NAMES kde-geo-uri-handler
    AUTO_CLEAN
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(GLOB LICENSE_FILES "${SOURCE_PATH}/LICENSES/*")
vcpkg_install_copyright(FILE_LIST ${LICENSE_FILES})
