vcpkg_download_distfile(ARCHIVE
  URLS "https://www.scintilla.org/scintilla550.zip"
  FILENAME "scintilla550.zip"
  SHA512 6e6dac00a6be902e64abdb6687887ef3c956cbeaf0ea5e05ce99af6876b5b57898c3633b38b9f975e6b06d3d4e17c6e6b6d4c51b0982b5e3375422af046830d1
)

if (VCPKG_LIBRARY_LINKAGE STREQUAL "static")
  list(APPEND PATCHES 0001-static-lib.patch)
endif()

if(VCPKG_CRT_LINKAGE STREQUAL "static")
  list(APPEND PATCHES 0002-static-crt.patch)
endif()

vcpkg_extract_source_archive(
  SOURCE_PATH
  ARCHIVE ${ARCHIVE}
  SOURCE_BASE 5.5.0
  PATCHES ${PATCHES}
)

vcpkg_install_msbuild(
  SOURCE_PATH "${SOURCE_PATH}"
  PROJECT_SUBPATH Win32/Scintilla.vcxproj
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/License.txt")
file(INSTALL "${SOURCE_PATH}/include/" DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}" FILES_MATCHING PATTERN "*.*")
