vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/threadweaver
    REF "v${VERSION}"
    SHA512 bc9d8f8a08ce2c8b5cf03aeccd0067c56feda38648fb48c80a0f1421b9c10e68e42a0f745740dcaa027688514fbb691aa8b40bc698218b52f759c3910f8cbb09
    HEAD_REF master
    PATCHES
        disable-examples.patch
)

# Prevent KDEClangFormat from writing to source effectively blocking parallel configure
file(WRITE "${SOURCE_PATH}/.clang-format" "DisableFormat: true\nSortIncludes: false\n")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_Qt6Tools=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Qt6ToolsTools=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME kf6threadweaver CONFIG_PATH lib/cmake/KF6ThreadWeaver)
vcpkg_copy_pdbs()


file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(GLOB LICENSE_FILES "${SOURCE_PATH}/LICENSES/*")
vcpkg_install_copyright(FILE_LIST ${LICENSE_FILES})
