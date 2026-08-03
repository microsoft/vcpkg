vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO HOST-Oman/libraqm
    REF v${VERSION}
    SHA512 636193a92233d4b76e0343927a6adabe770bac1338317e59d12537fd31c41cb988dfa049bd76bf83778b5f8cdc1ca5a7eba06bfcc085f8d2e5b25bdf38b0a711
    HEAD_REF master
    PATCHES
        prefer-pkgconfig-freetype.patch
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
