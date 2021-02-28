set(VERSION 4.16.0)

vcpkg_download_distfile(ARCHIVE
    URLS "https://ftp.gnu.org/gnu/libtasn1/libtasn1-${VERSION}.tar.gz"
    FILENAME "libtasn1-${VERSION}.tar.gz"
    SHA512 b356249535d5d592f9b59de39d21e26dd0f3f00ea47c9cef292cdd878042ea41ecbb7c8d2f02ac5839f5210092fe92a25acd343260ddf644887b031b167c2e71
)

vcpkg_extract_source_archive_ex(
   OUT_SOURCE_PATH SOURCE_PATH
   ARCHIVE ${ARCHIVE} 
   REF ${VERSION}
)

# restore the default ac_cv_prog_cc_g flags, otherwise it fails to compile
set(VCPKG_C_FLAGS "-g -O2") 
set(VCPKG_CXX_FLAGS "-g -O2")

vcpkg_configure_make(
    AUTOCONFIG
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        --disable-doc
)

vcpkg_install_make()
vcpkg_fixup_pkgconfig() 
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
