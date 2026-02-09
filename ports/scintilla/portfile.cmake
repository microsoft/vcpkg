vcpkg_download_distfile(ARCHIVE
  URLS "https://www.scintilla.org/scintilla558.zip"
  FILENAME "scintilla558.zip"
  SHA512 b1cb0249426331c9fa14e3d3908be629814b10cba552f40ee7e7fe93957994a49550dd0ecb5a3d21d44f91ae9ba91f5fc3c1248700ddebcc7cd41334dc41adaf
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
  SOURCE_BASE 5.5.8
  PATCHES ${PATCHES}
)

vcpkg_install_msbuild(
  SOURCE_PATH "${SOURCE_PATH}"
  PROJECT_SUBPATH Win32/Scintilla.vcxproj
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/License.txt")
file(INSTALL "${SOURCE_PATH}/include/" DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}" FILES_MATCHING PATTERN "*.*")
