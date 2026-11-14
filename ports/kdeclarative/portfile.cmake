vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/kdeclarative
    REF "v${VERSION}"
    SHA512 913ad7da802becf5c71ce45deae9d07a6168b51497f4e16e4b93a915124611b528c0b1d395c854111ba2c76494007fdf2e941c18ad739bd92a9a607e4db7b896
    HEAD_REF master
    PATCHES
        export-qml-modules.patch
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
        -DKDE_INSTALL_QMLDIR=Qt6/qml
        ${FEATURE_OPTIONS}
    # Used by ecm_find_qmlmodule(org.kde.ki18n)
    OPTIONS_RELEASE
        "-DCMAKE_INCLUDE_PATH=${CURRENT_INSTALLED_DIR}/Qt6/qml/org/kde/ki18n"
    OPTIONS_DEBUG
        "-DCMAKE_INCLUDE_PATH=${CURRENT_INSTALLED_DIR}/debug/Qt6/qml/org/kde/ki18n"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME kf6declarative CONFIG_PATH lib/cmake/KF6Declarative)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static" AND NOT VCPKG_BUILD_TYPE)
    # The static QML module objects are installed in the QML directory, debug/Qt6/qml for the debug build
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/kf6declarative/KF6DeclarativeTargets-debug.cmake"
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
