vcpkg_download_distfile(ARCHIVE
  URLS "https://www.scintilla.org/lexilla545.zip"
  FILENAME "lexilla545.zip"
  SHA512 03e590a883e31135abc7eccdd089fbe3fe074955db70cbd546b58f32a77109f252c2283519e43f6a6e4c69fae9a99912c2bd828a771ceebeabf67655dde45877
)

if (VCPKG_LIBRARY_LINKAGE STREQUAL "static")
  list(APPEND PATCHES 0001-static-lib.patch)
endif()

if(VCPKG_CRT_LINKAGE STREQUAL "static")
  list(APPEND PATCHES 0002-static-crt.patch)
endif()

list(APPEND PATCHES 0003-fix-include-path.patch)

vcpkg_extract_source_archive(
  SOURCE_PATH
  ARCHIVE ${ARCHIVE}
  SOURCE_BASE ${VERSION}
  PATCHES ${PATCHES}
)

vcpkg_install_msbuild(
  SOURCE_PATH "${SOURCE_PATH}"
  PROJECT_SUBPATH src/Lexilla.vcxproj
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/License.txt")
file(INSTALL "${SOURCE_PATH}/include/" DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}" FILES_MATCHING PATTERN "*.*")
file(INSTALL "${SOURCE_PATH}/lexlib/" DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}/lexlib" FILES_MATCHING PATTERN "*.h")
