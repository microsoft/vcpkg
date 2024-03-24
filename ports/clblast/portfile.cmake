vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CNugteren/CLBlast
    REF "${VERSION}"
    SHA512 43920c52b134367c2df86e9019cd3bab2811cf3a6bbc3de780724f4e62239ebaf390635d9dfbd887089753ccb751f7e94a9038c4a8aa23ac1a38f39cde5afdcc
    HEAD_REF master
    PATCHES
        fix_install_path.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DTUNERS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/CLBlast)
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
