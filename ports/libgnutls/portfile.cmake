vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gnutls/gnutls
    REF 3.6.15
    SHA512 85005b159048b7b47b3fc77e8be5b5b317b1ae73ef536d4e2d78496763b7b8c4f80c70016ed27fc60e998cbc7642d3cf487bd4c5e5a5d8abc8f8d51e02f330d1
    HEAD_REF master
)

vcpkg_configure_make(
    AUTOCONFIG
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        --disable-doc
        --disable-silent-rules
        --disable-tests
        --disable-maintainer-mode
        --disable-rpath
)

vcpkg_install_make()
vcpkg_fixup_pkgconfig() 
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(INSTALL ${SOURCE_PATH}/COPYING.LIB DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)