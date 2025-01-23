vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO intel/libva
    REF "${VERSION}"
    SHA512 cd633e5e09eac1ed10f1fc12b0f664f836e0eda9e47c17e1295b746cfd643a18fd0564a06a148ced3cf1e2321aa4d21275918bcf8c717d3981e98a598179f370
    HEAD_REF master
)

set(options "")

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${options}
)

vcpkg_install_meson()
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)