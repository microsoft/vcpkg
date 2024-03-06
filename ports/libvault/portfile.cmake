vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            abedra/libvault
    REF             0.56.0
    SHA512          6a8d14a755ea3d39c2912ee6d33cec9c6f30a498c57efc40603cecbbd90d400dba52be7b42287c87cd425694c89edbae86218021b2beaa5edca748c3d5dd7c77
    PATCHES
        0001-fix-dependencies.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DENABLE_TEST=OFF
        -DLINK_CURL=ON
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME libvault CONFIG_PATH lib/cmake/libvault)
vcpkg_fixup_pkgconfig()

vcpkg_copy_pdbs()


file(INSTALL "${SOURCE_PATH}/LICENSE"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
     RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include"
                    "${CURRENT_PACKAGES_DIR}/debug/share")

# Install usage
configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" @ONLY)
