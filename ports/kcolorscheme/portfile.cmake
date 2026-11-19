vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/kcolorscheme
    REF "v${VERSION}"
    SHA512 49e641ff19922556ee8e3a0518ad29144d8dcbfe986bf948673c86e4c322dcc94d49d12646deebdd54a86165fad6bd5b52ca37735a62a8546de79fe37aa39fe8
    HEAD_REF master
    PATCHES
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
vcpkg_cmake_config_fixup(PACKAGE_NAME kf6colorscheme CONFIG_PATH lib/cmake/KF6ColorScheme)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

file(GLOB LICENSE_FILES "${SOURCE_PATH}/LICENSES/*")
vcpkg_install_copyright(FILE_LIST ${LICENSE_FILES})
