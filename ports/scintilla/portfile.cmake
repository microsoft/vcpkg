include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY ONLY_DYNAMIC_CRT)

vcpkg_download_distfile(ARCHIVE
  URLS "http://www.scintilla.org/scintilla412.zip"
  FILENAME "scintilla412.zip"
  SHA512 10e24a2def5b3104b0f2eec473c53edb0a0cc19fbbef261e460a77415ec68ff83f9ee20c76cda7987627708c1d4ead5f964d4d5a98929d8256280bfa9bd0cddc
)
vcpkg_extract_source_archive_ex(
  OUT_SOURCE_PATH SOURCE_PATH
  ARCHIVE ${ARCHIVE}
  REF 4.1.2
)

vcpkg_install_msbuild(
  SOURCE_PATH ${SOURCE_PATH}
  PROJECT_SUBPATH Win32/SciLexer.vcxproj
  INCLUDES_SUBPATH include
  LICENSE_SUBPATH License.txt
  ALLOW_ROOT_INCLUDES
)
