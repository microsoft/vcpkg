vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            abedra/libvault
    REF "${VERSION}"
    SHA512 dc3295acafd1f9038430d8df00e96feb2252db0350716bd8a32c33d06a462a7ceb2c920458ca23bd42f5c14384fa1078ab4f69ff0817aa96b4e16ce03ddeddc2
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
