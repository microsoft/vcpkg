vcpkg_download_distfile(GUILE_ARCHIVE 
      URLS https://ftp.gnu.org/gnu/guile/guile-3.0.8.tar.gz
      FILENAME guile-3.0.8.tar.gz
      SHA512 7b2728e849a3ee482fe9a167dd76cc4835e911cc94ca0724dd51e8a813a240c6b5d2de84de16b46469ab24305b5b153a3c812fec942e007d3310bba4d1cf947d
  )

vcpkg_extract_source_archive(GUILE_SOURCES ARCHIVE ${GUILE_ARCHIVE})

vcpkg_configure_make(
    SOURCE_PATH "${GUILE_SOURCES}"
    ADD_BIN_TO_PATH
    AUTOCONFIG
  )
vcpkg_install_make()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_fixup_pkgconfig()

file(
    INSTALL "${GUILE_SOURCES}/COPYING.LESSER" 
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" 
    RENAME copyright
  )
