vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/ktexttemplate
    REF "v${VERSION}"
    SHA512 bfc89e572ffbb5f906c11888882e2d2e99f206ce5397fa9805de35f316709d0be2b20e58dc691077201784583bd5632bfb7ce0e82f50e6c527a5bf73fdc6dd24
    HEAD_REF master
)

# Prevent KDEClangFormat from writing to source effectively blocking parallel configure
file(WRITE "${SOURCE_PATH}/.clang-format" "DisableFormat: true\nSortIncludes: false\n")

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        qml CMAKE_REQUIRE_FIND_PACKAGE_Qt6Qml
    INVERTED_FEATURES
        qml CMAKE_DISABLE_FIND_PACKAGE_Qt6Qml
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DKDE_INSTALL_QTPLUGINDIR=Qt6/plugins
        -DCMAKE_DISABLE_FIND_PACKAGE_Qt6Tools=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Qt6ToolsTools=ON
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME kf6texttemplate CONFIG_PATH lib/cmake/KF6TextTemplate)
if(NOT VCPKG_BUILD_TYPE)
    # The plugins of the debug build are installed in debug/Qt6/plugins
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/kf6texttemplate/KF6TextTemplateTargets-debug.cmake"
        [[${_IMPORT_PREFIX}/Qt6/plugins/]]
        [[${_IMPORT_PREFIX}/debug/Qt6/plugins/]]
    )
endif()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

file(GLOB LICENSE_FILES "${SOURCE_PATH}/LICENSES/*")
vcpkg_install_copyright(FILE_LIST ${LICENSE_FILES})
