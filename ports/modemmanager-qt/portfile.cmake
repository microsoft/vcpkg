vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/modemmanager-qt
    REF "v${VERSION}"
    SHA512 d157baf8a29ccfa3ccb61a08962e285640e071a637fc10e932ec043e1c781dd846758698c98afbea056aafec69e967f4aae0dfe8deabecd298db571857e2ab21
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
