vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/plasma-wayland-protocols
    REF "v${VERSION}"
    SHA512 7c687d8bf0f4239bf1c977cf3014ce9b660cf3637e7811021c534d28d00e62fd46e4e9ad294d6e24e85a1ba6286badd17b1d6a62ea46d99e6ea51aeda5469950
    HEAD_REF master
)

# Prevent KDEClangFormat from writing to source effectively blocking parallel configure
file(WRITE "${SOURCE_PATH}/.clang-format" "DisableFormat: true\nSortIncludes: false\n")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME PlasmaWaylandProtocols CONFIG_PATH lib/cmake/PlasmaWaylandProtocols)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

file(GLOB LICENSE_FILES "${SOURCE_PATH}/LICENSES/*")
vcpkg_install_copyright(FILE_LIST ${LICENSE_FILES})

# Allow empty include directory
set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)