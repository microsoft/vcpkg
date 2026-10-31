vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/bluez-qt
    REF "v${VERSION}"
    SHA512 8e9766fc1e23cb1b6f5db6ff78a484fe69f80a2872b98736ed4a62d6e8dc30688222c3d7751b57f540b4c89f492fc38924017c1fe5bbe298f14b704885ec97d6
    HEAD_REF master
    PATCHES
        fix-static-dependencies.patch
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
        -DCMAKE_DISABLE_FIND_PACKAGE_Qt6Tools=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Qt6ToolsTools=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Qt6Test=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Qt6QuickTest=ON
        -DKDE_INSTALL_QMLDIR=qml
        "-DECM_PKGCONFIG_INSTALL_DIR:PATH=${CURRENT_PACKAGES_DIR}/discard_pkgconfig"
        ${FEATURE_OPTIONS}
    MAYBE_UNUSED_VARIABLES
        ECM_PKGCONFIG_INSTALL_DIR
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME kf6bluezqt CONFIG_PATH lib/cmake/KF6BluezQt)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/discard_pkgconfig"
)

file(GLOB LICENSE_FILES "${SOURCE_PATH}/LICENSES/*")
vcpkg_install_copyright(FILE_LIST ${LICENSE_FILES})
