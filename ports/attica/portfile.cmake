vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/attica
    REF "v${VERSION}"
    SHA512 901bd714757728310651f3a47d4236e99cba4f79bde0a547c02529ad13e7e3b3845f6fee6c1d9e328e6b3ffdd449e88a3fe8fb7970ec97ae841a33dc6cae0195
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
