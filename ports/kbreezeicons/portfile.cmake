vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/breeze-icons
    REF "v${VERSION}"
    SHA512 7f3dc9bf0cb6b10cbbe52c03bb3cf19f83b603333d66efcf4b2759d7df3ff6d6ae69f3abb2a83fe38977717d272dd8c25e62ffe1627594233a48ad67d2550cc9
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
