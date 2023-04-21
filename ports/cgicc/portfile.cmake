set(CGICC_VERSION 3.2.19)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_download_distfile(ARCHIVE
    URLS "https://ftp.gnu.org/gnu/cgicc/cgicc-${CGICC_VERSION}.tar.gz" "https://www.mirrorservice.org/sites/ftp.gnu.org/gnu/cgicc/cgicc-${CGICC_VERSION}.tar.gz"
    FILENAME "cgicc-${CGICC_VERSION}.tar.gz"
    SHA512 c361923cf3ac876bc3fc94dffd040d2be7cd44751d8534f4cfa3545e9f58a8ec35ebcd902a8ce6a19da0efe52db67506d8b02e5cc868188d187ce3092519abdf
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        fix-define.patch
        fix-static-build.patch
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS_DEBUG
    -DDISABLE_INSTALL_HEADERS=ON
    -DDISABLE_INSTALL_TOOLS=ON
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

file(READ "${CURRENT_PACKAGES_DIR}/include/cgicc/CgiDefs.h" CGI_H)
if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
  string(REPLACE "#  ifdef CGICC_STATIC" "#  if 0" CGI_H "${CGI_H}")
else()
  string(REPLACE "#  ifdef CGICC_STATIC" "#  if 1" CGI_H "${CGI_H}")
endif()
file(WRITE "${CURRENT_PACKAGES_DIR}/include/cgicc/CgiDefs.h" "${CGI_H}")


file(INSTALL "${SOURCE_PATH}/COPYING.DOC" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
