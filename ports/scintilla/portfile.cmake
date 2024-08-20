vcpkg_download_distfile(ARCHIVE
  URLS "https://www.scintilla.org/scintilla551.zip"
  FILENAME "scintilla551.zip"
  SHA512 00a230cbdd6e41925eec71566143f4a0fc8e4a87eddb459e3b547835e0cc1a8773e450112468acddacebbf0d4252c9b7edc9d813804a144d6f090f96441b7e1b
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
