include(CMakePackageConfigHelpers)

vcpkg_download_distfile(ARCHIVE
    URLS "http://www.codesynthesis.com/download/odb/2.4/libodb-2.4.0.tar.gz"
    FILENAME "libodb-2.4.0.tar.gz"
    SHA512 f1311458634695eb6ba307ebfd492e3b260e7beb06db1c5c46df58c339756be4006322cdc4e42d055bf5b2ad14ce4656ddcafcc4e16c282034db8a77d255c3eb
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        fix-linux.patch
)
file(REMOVE "${SOURCE_PATH}/version")

file(COPY
  "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt"
  "${CMAKE_CURRENT_LIST_DIR}/config.unix.h.in"
  DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS_DEBUG
        -DLIBODB_INSTALL_HEADERS=OFF
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
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
