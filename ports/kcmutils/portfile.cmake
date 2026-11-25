vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/kcmutils
    REF "v${VERSION}"
    SHA512 98a05729610bbc25cd47703fd066501f3aadf26cd3a9d3291f8578916c11b397f59b595fc124472ee620559a479a2cf3a797003b0bf7617be20c69a270425219
    HEAD_REF master
    PATCHES
        export-qml-modules.patch
        fix-static-dependencies.patch
        install-static-logging-library.patch
)

# Prevent KDEClangFormat from writing to source effectively blocking parallel configure
file(WRITE "${SOURCE_PATH}/.clang-format" "DisableFormat: true\nSortIncludes: false\n")

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    INVERTED_FEATURES
        translations KF_SKIP_PO_PROCESSING
)

if(VCPKG_TARGET_IS_LINUX OR VCPKG_TARGET_IS_BSD)
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
        -DKDE_INSTALL_QMLDIR=Qt6/qml
        ${FEATURE_OPTIONS}
    OPTIONS_RELEASE
        "-DCMAKE_INCLUDE_PATH=${CURRENT_INSTALLED_DIR}/Qt6/qml/org/kde/kirigami"
    OPTIONS_DEBUG
        "-DCMAKE_INCLUDE_PATH=${CURRENT_INSTALLED_DIR}/debug/Qt6/qml/org/kde/kirigami"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME kf6kcmutils CONFIG_PATH lib/cmake/KF6KCMUtils)

# The host tooling targets are searched in ${KF6_HOST_TOOLING}/KF6KCMUtils, vcpkg installs them in share/kf6kcmutils
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/kf6kcmutils/KF6KCMUtilsConfig.cmake"
    "KF6KCMUtils/KF6KCMUtilsToolingTargets.cmake"
    "kf6kcmutils/KF6KCMUtilsToolingTargets.cmake"
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static" AND NOT VCPKG_BUILD_TYPE)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/kf6kcmutils/KF6KCMUtilsTargets-debug.cmake"
        [[${_IMPORT_PREFIX}/Qt6/qml/]]
        [[${_IMPORT_PREFIX}/debug/Qt6/qml/]]
    )
endif()

vcpkg_copy_pdbs()
vcpkg_copy_tools(TOOL_NAMES kcmdesktopfilegenerator kcmshell6 AUTO_CLEAN)

# Without [Paths] Qt would look for the plugins next to the tools
file(WRITE "${CURRENT_PACKAGES_DIR}/tools/${PORT}/qt.conf" [[
[Paths]
Prefix = ../..
Plugins = Qt6/plugins
Qml2Imports = Qt6/qml
Data = share
]])

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

file(GLOB LICENSE_FILES "${SOURCE_PATH}/LICENSES/*")
vcpkg_install_copyright(FILE_LIST ${LICENSE_FILES})
