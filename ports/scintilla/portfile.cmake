vcpkg_fail_port_install(ON_TARGET "Linux" "OSX" "UWP")

vcpkg_download_distfile(ARCHIVE
  URLS "https://www.scintilla.org/scintilla445.zip"
  FILENAME "scintilla445.zip"
  SHA512 bac25ee6e9b1ab3602a6fbf2f28f046f6da5c45dfd6e882df250760a254517ee9b05d95b816234b5145553f0a8da92016d7839a50624543c52fde7539ea08259
)

if (VCPKG_LIBRARY_LINKAGE STREQUAL "static")
  list(APPEND PATCHES 0001-static-lib.patch)
endif()

if(VCPKG_CRT_LINKAGE STREQUAL "static")
  list(APPEND PATCHES 0002-static-crt.patch)
endif()

vcpkg_extract_source_archive_ex(
  OUT_SOURCE_PATH SOURCE_PATH
  ARCHIVE ${ARCHIVE}
  REF 4.4.5
  PATCHES ${PATCHES}
)

vcpkg_install_msbuild(
  SOURCE_PATH ${SOURCE_PATH}
  PROJECT_SUBPATH Win32/SciLexer.vcxproj
  INCLUDES_SUBPATH include
  LICENSE_SUBPATH License.txt
  ALLOW_ROOT_INCLUDES
)
