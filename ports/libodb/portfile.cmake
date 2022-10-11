include(CMakePackageConfigHelpers)

vcpkg_download_distfile(ARCHIVE
    URLS "http://www.codesynthesis.com/download/odb/2.4/libodb-2.4.0.tar.gz"
    FILENAME "libodb-2.4.0.tar.gz"
    SHA512 f1311458634695eb6ba307ebfd492e3b260e7beb06db1c5c46df58c339756be4006322cdc4e42d055bf5b2ad14ce4656ddcafcc4e16c282034db8a77d255c3eb
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
)
file(REMOVE "${SOURCE_PATH}/version")

file(COPY
  ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt
  ${CMAKE_CURRENT_LIST_DIR}/config.unix.h.in
  DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS_DEBUG
        -DLIBODB_INSTALL_HEADERS=OFF
)

vcpkg_install_cmake()
file(READ ${CURRENT_PACKAGES_DIR}/debug/share/odb/odb_libodbConfig-debug.cmake LIBODB_DEBUG_TARGETS)
string(REPLACE "\${_IMPORT_PREFIX}" "\${_IMPORT_PREFIX}/debug" LIBODB_DEBUG_TARGETS "${LIBODB_DEBUG_TARGETS}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/odb/odb_libodbConfig-debug.cmake "${LIBODB_DEBUG_TARGETS}")
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(COPY ${CMAKE_CURRENT_LIST_DIR}/odbConfig.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/odb)
write_basic_package_version_file(${CURRENT_PACKAGES_DIR}/share/odb/odbConfigVersion.cmake
    VERSION 2.4.0
    COMPATIBILITY SameMajorVersion
)

set(LIBODB_HEADER_PATH ${CURRENT_PACKAGES_DIR}/include/odb/details/export.hxx)
file(READ ${LIBODB_HEADER_PATH} LIBODB_HEADER)
if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    string(REPLACE "#ifdef LIBODB_STATIC_LIB" "#if 1" LIBODB_HEADER ${LIBODB_HEADER})
else()
    string(REPLACE "#ifdef LIBODB_STATIC_LIB" "#if 0" LIBODB_HEADER ${LIBODB_HEADER})
endif()
file(WRITE ${LIBODB_HEADER_PATH} "${LIBODB_HEADER}")

vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
