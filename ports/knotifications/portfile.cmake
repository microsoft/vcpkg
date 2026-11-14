vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/knotifications
    REF "v${VERSION}"
    SHA512 5168cae0c2de69d88d8452cf9b4140a1723d608705ef17dfe07a9856e7400dcf20023e89f9c9332b7366e6f3f6656038b0c864361a2f8dc6507b8e6915bc7379
    HEAD_REF master
    PATCHES
        export-qml-modules.patch
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        qml          CMAKE_REQUIRE_FIND_PACKAGE_Qt6Qml
    INVERTED_FEATURES
        qml          CMAKE_DISABLE_FIND_PACKAGE_Qt6Qml
        translations KF_SKIP_PO_PROCESSING
)

# Prevent KDEClangFormat from writing to source effectively blocking parallel configure
file(WRITE "${SOURCE_PATH}/.clang-format" "DisableFormat: true\nSortIncludes: false\n")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_Qt6Tools=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Qt6ToolsTools=ON
        -DBUILD_PYTHON_BINDINGS=OFF
        -DKDE_INSTALL_QMLDIR=Qt6/qml
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME kf6notifications CONFIG_PATH lib/cmake/KF6Notifications)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static" AND "qml" IN_LIST FEATURES AND NOT VCPKG_BUILD_TYPE)
    # The static QML module objects are installed in the QML directory, debug/Qt6/qml for the debug build
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/kf6notifications/KF6NotificationsTargets-debug.cmake"
        [[${_IMPORT_PREFIX}/Qt6/qml/]]
        [[${_IMPORT_PREFIX}/debug/Qt6/qml/]]
    )
endif()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

file(GLOB LICENSE_FILES "${SOURCE_PATH}/LICENSES/*")
vcpkg_install_copyright(FILE_LIST ${LICENSE_FILES})
