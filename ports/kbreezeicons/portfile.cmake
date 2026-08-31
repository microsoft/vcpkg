vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/breeze-icons
    REF "v${VERSION}"
    SHA512 d3af55f94fcade52a0662a9f51ddb67b46ba588e22d618ce3a236d4cdeb170f652d6673916f5b3b1093d04a751b33aacf4b4000e05cbe06ea9d746e7643ada45
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
