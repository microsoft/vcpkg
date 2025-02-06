vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nimbuscontrols/EIPScanner
    REF ${VERSION}
    SHA512 24612e6eec97aa67dfd83ec90d3f1a961c69a63a17cb09679b9eb453750049628def8d488b9debbf1f322a800f9f54933dedca9b37fb1c5703e95460b89f2f43
    HEAD_REF master
    PATCHES
        package.patch
)
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/eipscanner)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
