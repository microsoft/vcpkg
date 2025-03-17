vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            abedra/libvault
    REF "${VERSION}"
    SHA512 20a7e8ae5bac5278ff2c9588d24f853b0c80169e008e930c390a78e15d18f36c68c2666a4c6c4aa263689d5b89a8c9945eead4d88087035fafb9865fcc3466ca
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
