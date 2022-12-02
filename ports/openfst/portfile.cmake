vcpkg_download_distfile(
  ARCHIVE
  URLS https://www.openfst.org/twiki/pub/FST/FstDownload/openfst-1.8.2.tar.gz
  FILENAME openfst-1.8.2.tar.gz
  SHA512 ca7f9f19e24141e1f1d0bbabf43795e6e278bce3887c14261d9ce204a0e01b1588eaf982755a9105247510a19f67da2f566e9b14b1d869497148f95b55606d5c
)

vcpkg_extract_source_archive(SOURCE_PATH ARCHIVE "${ARCHIVE}")

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
)

vcpkg_install_make()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
