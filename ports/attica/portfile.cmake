vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/attica
    REF "v${VERSION}"
    SHA512 7859ea25fee632d5abe90a31f84297f6d8c3b65c115c56e64106f73756107567060cc8d5651553f216b64ee47c1c99e921d81f0b0a2fe6c409d8bf24ee9abc4b
    HEAD_REF master
)

# Prevent KDEClangFormat from writing to source effectively blocking parallel configure
file(WRITE "${SOURCE_PATH}/.clang-format" "DisableFormat: true\nSortIncludes: false\n")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_Qt6Tools=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Qt6ToolsTools=ON
        "-DECM_PKGCONFIG_INSTALL_DIR:PATH=${CURRENT_PACKAGES_DIR}/discard_pkgconfig"
    MAYBE_UNUSED_VARIABLES
        ECM_PKGCONFIG_INSTALL_DIR
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME kf6attica CONFIG_PATH lib/cmake/KF6Attica)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/discard_pkgconfig"
)

file(GLOB LICENSE_FILES "${SOURCE_PATH}/LICENSES/*")
vcpkg_install_copyright(FILE_LIST ${LICENSE_FILES})
