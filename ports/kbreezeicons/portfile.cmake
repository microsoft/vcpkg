vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/breeze-icons
    REF "v${VERSION}"
    SHA512 ed1319c56aa68b266090f53628dd2f47852d47af3d5d72bbd8f8c6996cc2528e139e4237548a7a71f13b40b9ff9c5e1880bf02175d28ea7276c6cde708db894c
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
