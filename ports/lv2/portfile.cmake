vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lv2/lv2
    REF "v${VERSION}"
    SHA512 d63a223b1e1ab9282392637ea2878cfca5dc466553dcea45fb6d8bc5fe657d0705f01db45affcda29344166fba2738a33da5c15ef44ceec58989e406131e1ded
    HEAD_REF main
)

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Ddocs=disabled
        -Dplugins=disabled
        -Dtests=disabled
)

vcpkg_install_meson()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/lv2-config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
