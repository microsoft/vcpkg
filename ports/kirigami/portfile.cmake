vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/kirigami
    REF "v${VERSION}"
    SHA512 b0c57918dc95ec5d1e031635d9406d918946e9399d914b8c9a482fa5b756f66d0d900865e94c7d84905a744b48fc20f4201376e654c1e9acd903f55ac5ab137f
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
