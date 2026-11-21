vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/knewstuff
    REF "v${VERSION}"
    SHA512 e7590c315e1fb0e4f3bae3908506008cc4b4c70e02b67914abbd2b3afee7575cef211275cf8e09536be542dc30f8cf6394da57ce060e180d1975c40189657650
    HEAD_REF master
    PATCHES
        export-qml-modules.patch
        fix-static-dependencies.patch
        install-static-jobs-library.patch
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

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_Qt6Tools=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Qt6ToolsTools=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_KF6Syndication=ON
        -DKDE_INSTALL_QTPLUGINDIR=Qt6/plugins
        -DKDE_INSTALL_QMLDIR=Qt6/qml
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME kf6newstuffcore CONFIG_PATH lib/cmake/KF6NewStuffCore DO_NOT_DELETE_PARENT_CONFIG_PATH)
vcpkg_cmake_config_fixup(PACKAGE_NAME kf6newstuff CONFIG_PATH lib/cmake/KF6NewStuff)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static" AND NOT VCPKG_BUILD_TYPE)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/kf6newstuff/KF6NewStuffTargets-debug.cmake"
        [[${_IMPORT_PREFIX}/Qt6/qml/]]
        [[${_IMPORT_PREFIX}/debug/Qt6/qml/]]
    )
endif()

vcpkg_copy_pdbs()
vcpkg_copy_tools(TOOL_NAMES knewstuff-dialog6 AUTO_CLEAN)

# Without [Paths] Qt would look for the plugins next to the tools
file(WRITE "${CURRENT_PACKAGES_DIR}/tools/${PORT}/qt.conf" [[
[Paths]
Prefix = ../..
Plugins = Qt6/plugins
Qml2Imports = Qt6/qml
Data = share
]])

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

file(GLOB LICENSE_FILES "${SOURCE_PATH}/LICENSES/*")
vcpkg_install_copyright(FILE_LIST ${LICENSE_FILES})
