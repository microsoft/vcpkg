vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO drobilla/zix
    REF "v${VERSION}"
    SHA512 806b6b2e48bd0f1205958a63dd8aea73edb4b791c158cf9087c8fb2fad1111459ee6ed06428e04962ec98da4c38796b5c419573e0ffb65bdc5e7a1342387ef79
    HEAD_REF main
)

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Dbenchmarks=disabled
        -Ddocs=disabled
        -Dtests=disabled
        -Dtests_cpp=disabled
)

vcpkg_install_meson()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
