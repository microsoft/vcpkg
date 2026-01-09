vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO HOST-Oman/libraqm
    REF v${VERSION}
    SHA512 ba0b16ac2240580c3091ff8b673c10345b94c54dff7e102b893855e3d33a1396c681025d3326e53f5ebcde97ceef6ab4dfd9366d0864b422e578d38146692b62
    HEAD_REF master
)

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_install_meson()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
