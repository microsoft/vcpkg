vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gul-cpp/gul17
    REF "v${VERSION}"
    SHA512 afb4cddfe50da000880c51cded6961ae9720152a67a7440612ccf324ff7af646476ff0d1a287f14ad36b95d5cecc17be239f487e281d80b4a9ac1813d2f46f76
    HEAD_REF main
)

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS -Dtests=false
)

vcpkg_install_meson()
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

# Install copyright file
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/license.txt")
