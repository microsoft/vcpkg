vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/threadweaver
    REF "v${VERSION}"
    SHA512 177f1e9c71fe0b7008a916388fcc95f1da86b7f72a7954ee072d361d336233ea8d9cfb2e78442d985dc8b0f3f7e8dd2f3cc1a51f120cb43c20806e72166c14b9
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
vcpkg_cmake_config_fixup(PACKAGE_NAME kf6threadweaver CONFIG_PATH lib/cmake/KF6ThreadWeaver)
vcpkg_copy_pdbs()


file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(GLOB LICENSE_FILES "${SOURCE_PATH}/LICENSES/*")
vcpkg_install_copyright(FILE_LIST ${LICENSE_FILES})
