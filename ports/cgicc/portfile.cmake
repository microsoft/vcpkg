vcpkg_download_distfile(ARCHIVE
    URLS
        "https://ftpmirror.gnu.org/cgicc/cgicc-${VERSION}.tar.gz"
        "https://ftp.gnu.org/gnu/cgicc/cgicc-${VERSION}.tar.gz"
        "https://www.mirrorservice.org/sites/ftp.gnu.org/gnu/cgicc/cgicc-${VERSION}.tar.gz"
    FILENAME "cgicc-${VERSION}.tar.gz"
    SHA512 e57b8f30b26b29008bcf1ffc3b2d272bdbd77848fb02e24912b6182ae90923d5933b9d204c556ac922a389f73ced465065b6e2202fc0c3d008e0e6038e7c8052
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
    OPTIONS
        -DCMAKE_CXX_STANDARD=11 # 17 removes std::unary_function
    OPTIONS_DEBUG
        -DDISABLE_INSTALL_HEADERS=ON
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

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING.DOC")
