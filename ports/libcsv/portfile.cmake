if(EXISTS "${CURRENT_INSTALLED_DIR}/share/fast-cpp-csv-parser/copyright")
    message(FATAL_ERROR "'${PORT}' conflicts with 'fast-cpp-csv-parser'. Please remove fast-cpp-csv-parser:${TARGET_TRIPLET}, and try to install ${PORT}:${TARGET_TRIPLET} again.")
endif()

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
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
