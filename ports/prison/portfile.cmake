vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/prison
    REF "v${VERSION}"
    SHA512 ff3ed91426bcfece8e812d988997f3d9020e2988072519f53b7ee2483d2bfc93f6d2e0e7937838f984740e9f67f6ad8a2ff13265e1807184743d68bb1ecdadd1
    HEAD_REF master
    PATCHES
        fix-qml-condition.patch
        optional-scanner-qml.patch
        fix-scanner-config-dependencies.patch
        fix-qrencode-debug-library.patch
        fix-dmtx-configurations.patch
)

# Prevent KDEClangFormat from writing to source effectively blocking parallel configure
file(WRITE "${SOURCE_PATH}/.clang-format" "DisableFormat: true\nSortIncludes: false\n")

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        datamatrix  WITH_DMTX
        qml         WITH_QUICK
        scanner     WITH_MULTIMEDIA
        scanner-qml WITH_SCANNER_QUICK
        zxing       WITH_ZXING
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_Qt6Tools=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Qt6ToolsTools=ON
        -DKDE_INSTALL_QMLDIR=Qt6/qml
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
if("scanner" IN_LIST FEATURES)
    vcpkg_cmake_config_fixup(PACKAGE_NAME kf6prisonscanner CONFIG_PATH lib/cmake/KF6PrisonScanner DO_NOT_DELETE_PARENT_CONFIG_PATH)
endif()
vcpkg_cmake_config_fixup(PACKAGE_NAME kf6prison CONFIG_PATH lib/cmake/KF6Prison)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

file(GLOB LICENSE_FILES "${SOURCE_PATH}/LICENSES/*")
vcpkg_install_copyright(FILE_LIST ${LICENSE_FILES})
