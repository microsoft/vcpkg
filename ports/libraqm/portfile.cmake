vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO HOST-Oman/libraqm
    REF v${VERSION}
    SHA512 7d7c1d252fd48ec7fba64b0ba1bfc5dbfb3d41a1022db78617f40fe189f09d3954ba6182aea000364b14ce0637711cbe5541c7cff28f9ad429ce16fa97aa8027
    HEAD_REF master
)

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Dtests=false
)

vcpkg_install_meson()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
