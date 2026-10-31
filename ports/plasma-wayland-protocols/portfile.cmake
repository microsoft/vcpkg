vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/plasma-wayland-protocols
    REF "v${VERSION}"
    SHA512 4d660d3b5beac22e988e4c1e6573ac35d09ac1d27d87d7726002faa81f01cdcfc76c7b2098fd96377e423e1bc958335612e434dd194aed9f3ae0f4f442847e35
    HEAD_REF master
)

# Prevent KDEClangFormat from writing to source effectively blocking parallel configure
file(WRITE "${SOURCE_PATH}/.clang-format" "DisableFormat: true\nSortIncludes: false\n")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME PlasmaWaylandProtocols CONFIG_PATH share/cmake/PlasmaWaylandProtocols)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

file(GLOB LICENSE_FILES "${SOURCE_PATH}/LICENSES/*")
vcpkg_install_copyright(FILE_LIST ${LICENSE_FILES})

# Allow empty include directory
set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
