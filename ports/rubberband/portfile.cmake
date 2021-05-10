vcpkg_download_distfile(
  ARCHIVE URLS "https://breakfastquay.com/files/releases/rubberband-1.9.1.tar.bz2"
  FILENAME "rubberband-1.9.1.tar.bz2"
  SHA512 cb20ef8fb717a9e6b5b0b921541bd701e94326e12cdb20d50bed344d12fa1b4fd731335c3a0a7f2d2a5ce96031d965b209e7667c4d55fd8494b8e20d3409f0d3
)

vcpkg_extract_source_archive_ex(
  OUT_SOURCE_PATH SOURCE_PATH
  ARCHIVE ${ARCHIVE}
)

vcpkg_configure_meson(SOURCE_PATH ${SOURCE_PATH})

vcpkg_install_meson()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
  file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(
  INSTALL ${SOURCE_PATH}/COPYING
  DESTINATION ${CURRENT_PACKAGES_DIR}/share/rubberband
  RENAME copyright
)
