vcpkg_download_distfile(ARCHIVE
    URLS "https://pkg.cppget.org/1/beta/odb/libodb-${VERSION}.tar.gz"
    FILENAME "libodb-${VERSION}.tar.gz"
    SHA512 f99eba87130f7c3ed0b707e1f4efdb839c97c221fee24056d955072767c36106297abe76e5f82054cf5bc3bf0fda631e7c92e4943645d6ff2be57831006505ef
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
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
