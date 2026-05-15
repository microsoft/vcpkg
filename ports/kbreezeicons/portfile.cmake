vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/breeze-icons
    REF "v${VERSION}"
    SHA512 50954322f37f6b16fb02aec42334aebe0094cf27918d78ed981d52f5e23076bbc95358e700157ecbfad50aba8c8b7cad8f234c6216209effafda7c73824e0d19
    HEAD_REF master
)

# Prevent KDEClangFormat from writing to source effectively blocking parallel configure
file(WRITE "${SOURCE_PATH}/.clang-format" "DisableFormat: true\nSortIncludes: false\n")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DWITH_ICON_GENERATION=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
    PACKAGE_NAME kf6breezeicons
    CONFIG_PATH lib/cmake/KF6BreezeIcons
)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/COPYING-ICONS"
        "${SOURCE_PATH}/COPYING.LIB"
)
