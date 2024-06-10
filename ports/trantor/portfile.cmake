vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO an-tao/trantor
    REF "v${VERSION}"
    SHA512 2dba27efad95155a76968959d9bd2510be8502b9424716493f385aebbce2481553cc8fae283076029aed4bef6f0aadb0bec3f9acb98fbca3ef4d49b936558f8c
    HEAD_REF master
    PATCHES
        000-fix-deps.patch
        001-disable-werror.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

# Fix CMake files
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/Trantor)

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/License" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

vcpkg_copy_pdbs()
