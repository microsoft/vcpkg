vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gnutls/libtasn1
    REF 4.16.0
    SHA512 e268aaddc3972b4e89db6b470a9b132ea89a33a0b4b61fadd4cfa149349ce7080a3f42d1cb0a18949330c9c0f14151ba666c6ae64babd44e6eb8a2c004500b27
    HEAD_REF master
)

vcpkg_configure_make(
    AUTOCONFIG
    COPY_SOURCE
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        --disable-doc
        --disable-silent-rules
)

vcpkg_install_make()
vcpkg_fixup_pkgconfig() 
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(INSTALL ${SOURCE_PATH}/COPYING.LIB DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)