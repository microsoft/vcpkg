vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/kcoreaddons
    REF "v${VERSION}"
    SHA512 c8b3841f648fbbb9e43e29bf90b476fe75010d57ff7b35444825128a33f524a02c8663afda1c244b4ed25fcdf87e1e20baabfb2a389d3573afe25a8144d29781
    HEAD_REF master
)

# Prevent KDEClangFormat from writing to source effectively blocking parallel configure
file(WRITE "${SOURCE_PATH}/.clang-format" "DisableFormat: true\nSortIncludes: false\n")

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        qml KCOREADDONS_USE_QML
    INVERTED_FEATURES
        translations KF_SKIP_PO_PROCESSING
)

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
vcpkg_cmake_config_fixup(
    PACKAGE_NAME kf6coreaddons
    CONFIG_PATH lib/cmake/KF6CoreAddons
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static" AND "qml" IN_LIST FEATURES AND NOT VCPKG_BUILD_TYPE)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/kf6coreaddons/KF6CoreAddonsTargets-debug.cmake"
        [[${_IMPORT_PREFIX}/Qt6/qml/]]
        [[${_IMPORT_PREFIX}/debug/Qt6/qml/]]
    )
endif()

vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig(SKIP_CHECK)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin/data/kf6")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin/data/kf6")

file(GLOB LICENSE_FILES "${SOURCE_PATH}/LICENSES/*")
vcpkg_install_copyright(FILE_LIST ${LICENSE_FILES})
