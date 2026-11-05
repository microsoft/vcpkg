vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/kuserfeedback
    REF "v${VERSION}"
    SHA512 a74c477f4d17b10743e880eed01d1bac03a9633172c0b5ee06063423ea8cc433471bc9cd7bdf9b6bddce3183f028cadaf5cc4d3628f823c01a746dbdbed1a68b
    HEAD_REF master
    PATCHES
        export-qml-modules.patch
        fix-qt-gui-dependency.patch
)

# Prevent KDEClangFormat from writing to source effectively blocking parallel configure
file(WRITE "${SOURCE_PATH}/.clang-format" "DisableFormat: true\nSortIncludes: false\n")

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        qml          CMAKE_REQUIRE_FIND_PACKAGE_Qt6Qml
        widgets      CMAKE_REQUIRE_FIND_PACKAGE_Qt6Widgets
    INVERTED_FEATURES
        qml          CMAKE_DISABLE_FIND_PACKAGE_Qt6Qml
        widgets      CMAKE_DISABLE_FIND_PACKAGE_Qt6Widgets
        translations KF_SKIP_PO_PROCESSING
)

vcpkg_find_acquire_program(FLEX)
vcpkg_find_acquire_program(BISON)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DENABLE_CONSOLE=OFF
        -DENABLE_DOCS=OFF
        -DENABLE_PHP=OFF
        -DENABLE_PHP_UNIT=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_QmlLint=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Qt6Charts=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Qt6PrintSupport=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Qt6Svg=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Qt6Test=ON
        -DKDE_INSTALL_QMLDIR=Qt6/qml
        "-DFLEX_EXECUTABLE=${FLEX}"
        "-DBISON_EXECUTABLE=${BISON}"
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME kf6userfeedback CONFIG_PATH lib/cmake/KF6UserFeedback)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static" AND "qml" IN_LIST FEATURES AND NOT VCPKG_BUILD_TYPE)
    # The static QML module objects are installed in the QML directory, debug/Qt6/qml for the debug build
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/kf6userfeedback/KF6UserFeedbackTarget-debug.cmake"
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
