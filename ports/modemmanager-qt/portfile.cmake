vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/modemmanager-qt
    REF "v${VERSION}"
    SHA512 7765a59dd892151079a9647b0a4cd7d61161e3bd59ec9d6ae559ba727faa7c6f5f6ab094857d51d3f817ad16068a98201a530686ffa8c5240832223e178568eb
    HEAD_REF master
    PATCHES
        fix-static-library.patch
        fix-static-dependencies.patch
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
vcpkg_cmake_config_fixup(PACKAGE_NAME kf6modemmanagerqt CONFIG_PATH lib/cmake/KF6ModemManagerQt)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

file(GLOB LICENSE_FILES "${SOURCE_PATH}/LICENSES/*")
vcpkg_install_copyright(FILE_LIST ${LICENSE_FILES})
