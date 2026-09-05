vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/knotifications
    REF "v${VERSION}"
    SHA512 5fb338cb4d58f7e3f0588524e8cf7a9934cd7a4218c0ddadca5a14fa98686c436e4632dc6067a45547fd97d0dd865add8837cffa8490c5797f3e37b1c106f621
    HEAD_REF master
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    INVERTED_FEATURES
        translations KF_SKIP_PO_PROCESSING
)

# Prevent KDEClangFormat from writing to source effectively blocking parallel configure
file(WRITE "${SOURCE_PATH}/.clang-format" "DisableFormat: true\nSortIncludes: false\n")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DBUILD_PYTHON_BINDINGS=OFF
        -DKDE_INSTALL_QMLDIR=qml
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME kf6notifications CONFIG_PATH lib/cmake/KF6Notifications)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(GLOB LICENSE_FILES "${SOURCE_PATH}/LICENSES/*")
vcpkg_install_copyright(FILE_LIST ${LICENSE_FILES})
