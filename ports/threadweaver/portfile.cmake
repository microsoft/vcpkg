vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/threadweaver
    REF "v${VERSION}"
    SHA512 b1516e805ff465a6dd5884954e636fdfcb3407046d5faaff98c2bbbd43b15da0d7fa8edc1fbb5a03e56a04a1354580fb798f964926ff62a250dbe05d5c3b6c23
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
