vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/kcoreaddons
    REF "v${VERSION}"
    SHA512 9a952e6fbb782139947924ac825858d32095ff03d2d6ef5940f5ec9149af7d0d8171d9951831bb9ddb25e772939636ad5e207184f5ad9261cbf63438fcd7f561
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
        -DBUILD_PYTHON_BINDINGS=OFF
        -DKDE_INSTALL_QMLDIR=qml
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
    PACKAGE_NAME kf6coreaddons
    CONFIG_PATH lib/cmake/KF6CoreAddons
)
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig(SKIP_CHECK)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin/data/kf6")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin/data/kf6")

file(GLOB LICENSE_FILES "${SOURCE_PATH}/LICENSES/*")
vcpkg_install_copyright(FILE_LIST ${LICENSE_FILES})
