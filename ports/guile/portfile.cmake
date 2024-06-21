vcpkg_download_distfile(GUILE_ARCHIVE 
      URLS https://ftp.gnu.org/gnu/guile/guile-${VERSION}.tar.gz
      FILENAME guile-${VERSION}.tar.gz
      SHA512 6fd14f0860c7f5b7a9b53c43a60c6a7ca53072684ddc818cd10c720af2c5761ef110b29af466b89ded884fb66d66060894b14e615eaebee8844c397932d05fa2
  )

vcpkg_extract_source_archive(GUILE_SOURCES ARCHIVE ${GUILE_ARCHIVE})

vcpkg_add_to_path("${CURRENT_HOST_INSTALLED_DIR}/tools/gperf")

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
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug/bin/${file}" "${CURRENT_INSTALLED_DIR}/debug/../tools/guile/debug/bin" "`dirname $0`" IGNORE_UNCHANGED)
  endforeach()
  vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug/bin/guile-config" "${CURRENT_INSTALLED_DIR}" "`dirname $0`/../../../..")
endif()
foreach(file guile-tools guile-config guild)
  vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin/${file}" "${CURRENT_INSTALLED_DIR}/tools/guile/bin" "`dirname $0`" IGNORE_UNCHANGED)
endforeach()
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin/guile-config" "${CURRENT_INSTALLED_DIR}" "`dirname $0`/../../..")

file(
    INSTALL "${GUILE_SOURCES}/COPYING.LESSER" 
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" 
    RENAME copyright
  )
