vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/breeze-icons
    REF "v${VERSION}"
    SHA512 56f21a74c68768194ce16b2d4768fd21ccb385ef9911431a17c00976168e10fb33e978e5c1f7eb4311f861cca0a30f6bca8a907fbaac81be88425884478836a3
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
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/KF6BreezeIcons)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/COPYING-ICONS"
        "${SOURCE_PATH}/COPYING.LIB"
)
