vcpkg_download_distfile(ARCHIVE
    URLS "https://sourceforge.net/projects/xqilla/files/XQilla-2.3.4.tar.gz/download"
    FILENAME "XQilla-2.3.4.tar.gz"
    SHA512 f744ff883675887494780d24ecdc94afa394d3795d1544b1c598016b3f936c340ad7cd84529ac12962e3c5ce2f1be928a0cd4f9b9eb70e6645a38b0728cb1994
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    PATCHES "fix-compare.patch"
)

if (VCPKG_LIBRARY_LINKAGE STREQUAL "static")
   list(APPEND COMPILE_OPTIONS "-DXQILLA_STATIC=static")
endif()


file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    NO_CHARSET_FLAG
    OPTIONS ${COMPILE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()


file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/xqilla" RENAME copyright)
