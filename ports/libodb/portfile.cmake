vcpkg_download_distfile(ARCHIVE
    URLS "https://pkg.cppget.org/1/beta/odb/libodb-${VERSION}.tar.gz"
    FILENAME "libodb-${VERSION}.tar.gz"
    SHA512 d8091686e7d99345025754b7ce777c8fd000a355235064c45163cfff328fcac7b20b9eb145418a02b8ecec7b9c775efd3a94272e63512ba4f0181784391f5a92
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DCMAKE_CXX_STANDARD=11 # 17 removes 'auto_ptr'
    OPTIONS_DEBUG
        -DLIBODB_INSTALL_HEADERS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-libodb)

set(LIBODB_HEADER_PATH "${CURRENT_PACKAGES_DIR}/include/odb/details/export.hxx")
file(READ "${LIBODB_HEADER_PATH}" LIBODB_HEADER)
if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    string(REPLACE "#ifdef LIBODB_STATIC_LIB" "#if 1" LIBODB_HEADER "${LIBODB_HEADER}")
else()
    string(REPLACE "#ifdef LIBODB_STATIC_LIB" "#if 0" LIBODB_HEADER "${LIBODB_HEADER}")
endif()
file(WRITE "${LIBODB_HEADER_PATH}" "${LIBODB_HEADER}")

vcpkg_copy_pdbs()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
