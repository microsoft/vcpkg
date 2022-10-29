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

if (NOT VCPKG_BUILD_TYPE)
  foreach(file guile-tools guile-config guild)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug/bin/${file}" "${CURRENT_INSTALLED_DIR}/debug/../tools/guile/debug/bin" "`dirname $0`")
  endforeach()
  vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug/bin/guile-config" "${CURRENT_INSTALLED_DIR}" "`dirname $0`/../../../..")
endif()
foreach(file guile-tools guile-config guild)
  vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin/${file}" "${CURRENT_INSTALLED_DIR}/tools/guile/bin" "`dirname $0`")
endforeach()
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin/guile-config" "${CURRENT_INSTALLED_DIR}" "`dirname $0`/../../..")

file(
    INSTALL "${GUILE_SOURCES}/COPYING.LESSER" 
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" 
    RENAME copyright
  )
