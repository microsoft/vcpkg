vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/kquickcharts
    REF "v${VERSION}"
    SHA512 3af6ea79ae5395260be19b760702eb0bc3d214fc831809fcb3c54af66d1ac1a02b15fa9317b93f7b1d22885a7206eeb12425e65397f229a1e9c11b9956723946
    HEAD_REF master
    PATCHES
        export-controls.patch
        fix-config-dependencies.patch
)

# Prevent KDEClangFormat from writing to source effectively blocking parallel configure
file(WRITE "${SOURCE_PATH}/.clang-format" "DisableFormat: true\nSortIncludes: false\n")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_Qt6Tools=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Qt6ToolsTools=ON
        -DKDE_INSTALL_QMLDIR=Qt6/qml
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME kf6quickcharts CONFIG_PATH lib/cmake/KF6QuickCharts)
vcpkg_copy_pdbs()

set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static" AND NOT VCPKG_BUILD_TYPE)
    # The static QML module objects are installed in the QML directory, debug/Qt6/qml for the debug build
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/kf6quickcharts/KF6QuickChartsTargets-debug.cmake"
        [[${_IMPORT_PREFIX}/Qt6/qml/]]
        [[${_IMPORT_PREFIX}/debug/Qt6/qml/]]
    )
endif()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

file(GLOB LICENSE_FILES "${SOURCE_PATH}/LICENSES/*")
vcpkg_install_copyright(FILE_LIST ${LICENSE_FILES})
