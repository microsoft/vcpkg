vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO videolabs/libmicrodns
    REF 0.2.0
    SHA512 6389ad9edaf1af7c831e8c05e4800964b13cf0eed2063fa3675e7b87c49428ae7b68ac4ed1e742ed5d46ea3ded190e3de076e73ebf167422505257d7b1a03e25
    HEAD_REF master
)

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
)
vcpkg_install_meson()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

configure_file("${SOURCE_PATH}/COPYING" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)
