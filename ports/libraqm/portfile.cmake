vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO HOST-Oman/libraqm
    REF v${VERSION}
    SHA512 5b32753b000fa30fe6bb997b8719328c13d68e0ed74207436eff6f1d2932e02c53df424dbf9721cedb308efd355e00036dcfb2d26d7fd89f545273f0e3c24d72
    HEAD_REF master
)

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_install_meson()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
