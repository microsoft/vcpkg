vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/kirigami
    REF "v${VERSION}"
    SHA512 7163daab7af09afee6568d839243161b1027d50c642593460a5131922a1d7eecd3e33a3d35cc3a19076b66a24911094e6481490fbb2d3ef192d104cd5d2a37ca
    HEAD_REF master
    PATCHES
        fix-static-dependencies.patch
)

# Prevent KDEClangFormat from writing to source effectively blocking parallel configure
file(WRITE "${SOURCE_PATH}/.clang-format" "DisableFormat: true\nSortIncludes: false\n")

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    INVERTED_FEATURES
        translations KF_SKIP_PO_PROCESSING
)

if(VCPKG_TARGET_IS_LINUX)
    list(APPEND FEATURE_OPTIONS -DUSE_DBUS=ON)
else()
    list(APPEND FEATURE_OPTIONS -DUSE_DBUS=OFF)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE # configure_file() writes .qmllint.ini to the source directory
    OPTIONS
        -DBUILD_TESTING=OFF
        -DBUILD_EXAMPLES=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_Qt6Tools=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Qt6ToolsTools=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_OpenMP=ON
        -DKDE_INSTALL_QMLDIR=Qt6/qml
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME kf6kirigamiplatform CONFIG_PATH lib/cmake/KF6KirigamiPlatform DO_NOT_DELETE_PARENT_CONFIG_PATH)
vcpkg_cmake_config_fixup(PACKAGE_NAME kf6kirigami2 CONFIG_PATH lib/cmake/KF6Kirigami2 DO_NOT_DELETE_PARENT_CONFIG_PATH)
vcpkg_cmake_config_fixup(PACKAGE_NAME kf6kirigami CONFIG_PATH lib/cmake/KF6Kirigami)
vcpkg_copy_pdbs()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static" AND NOT VCPKG_BUILD_TYPE)
    # The static QML module objects are installed in the QML directory, debug/Qt6/qml for the debug build
    foreach(targets_debug IN ITEMS
        "${CURRENT_PACKAGES_DIR}/share/kf6kirigami/KF6KirigamiTargets-debug.cmake"
        "${CURRENT_PACKAGES_DIR}/share/kf6kirigamiplatform/KF6KirigamiPlatformTargets-debug.cmake"
    )
        vcpkg_replace_string("${targets_debug}"
            [[${_IMPORT_PREFIX}/Qt6/qml/]]
            [[${_IMPORT_PREFIX}/debug/Qt6/qml/]]
        )
    endforeach()
endif()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

file(GLOB LICENSE_FILES "${SOURCE_PATH}/LICENSES/*")
vcpkg_install_copyright(FILE_LIST ${LICENSE_FILES})
