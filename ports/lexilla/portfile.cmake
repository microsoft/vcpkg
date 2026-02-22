vcpkg_download_distfile(ARCHIVE
  URLS "https://www.scintilla.org/lexilla546.zip"
  FILENAME "lexilla546.zip"
  SHA512 7290de2acbe9e52cac31aa3bf89dae66faa2040b45e715a2e18d2dd5804b2486dac8ae1cec68d8dc9215fc953628d492dbf57e61751011d17c3d70899a47dec0
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
