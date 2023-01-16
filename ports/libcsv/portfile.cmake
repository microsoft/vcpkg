vcpkg_check_linkage(ONLY_STATIC_LIBRARY) 

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rgamble/libcsv
    REF b1d5212831842ee5869d99bc208a21837e4037d5 # v3.0.3
    SHA512 2e6ea0b68768d502e9bdb3bb801a1eb64b7fb0010a5006dec1b36a0fe705ec717560ec91f586572654c015db1f0d3a6e804dbcaa666a419192e93820b2c5e891
    HEAD_REF master    
    PATCHES
        Makefile.patch
)

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
)

vcpkg_install_make()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/libcsv" RENAME copyright)
