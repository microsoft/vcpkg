vcpkg_download_distfile(ARCHIVE
  URLS "https://www.scintilla.org/scintilla567.zip"
  FILENAME "scintilla567.zip"
  SHA512 ad25da6b8781fbb55a2e2904f6331c02817765f8abffdbbfe619890761e609f8490ebbc1261a03d6520846f9496cb65e7fbebbde09c46775959b38a7a02adfaf
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
  SOURCE_BASE 5.6.7
  PATCHES ${PATCHES}
)

vcpkg_install_msbuild(
  SOURCE_PATH "${SOURCE_PATH}"
  PROJECT_SUBPATH Win32/Scintilla.vcxproj
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/License.txt")
file(INSTALL "${SOURCE_PATH}/include/" DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}" FILES_MATCHING PATTERN "*.*")
