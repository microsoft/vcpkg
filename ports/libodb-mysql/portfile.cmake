vcpkg_download_distfile(ARCHIVE
    URLS "https://www.codesynthesis.com/download/odb/2.4/libodb-mysql-2.4.0.tar.gz"
    FILENAME "libodb-mysql-2.4.0.tar.gz"
    SHA512 c27b73c3f61dccdd149c11c122185f645a00d5bc346b366ee65b738f8719c39d03fad07a0d55b62b3db9e3ad2507679c24ddda331e5d110f367ad32f7cf8b910
)

vcpkg_extract_source_archive_ex(
    ARCHIVE ${ARCHIVE}
    OUT_SOURCE_PATH SOURCE_PATH
    PATCHES
        adapter_mysql_8.0.patch
        fix-redefinttion.patch
)
file(REMOVE "${SOURCE_PATH}/version")

file(COPY
  ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt
  ${CMAKE_CURRENT_LIST_DIR}/config.unix.h.in
  DESTINATION ${SOURCE_PATH})

set(MYSQL_INCLUDE_DIR "${CURRENT_INSTALLED_DIR}/include/mysql")
find_library(MYSQL_LIB NAMES libmysql mysqlclient PATH_SUFFIXES lib PATHS "${CURRENT_INSTALLED_DIR}" NO_DEFAULT_PATH REQUIRED)
find_library(MYSQL_LIB_DEBUG NAMES libmysql mysqlclient PATH_SUFFIXES lib PATHS "${CURRENT_INSTALLED_DIR}/debug" NO_DEFAULT_PATH REQUIRED)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    DISABLE_PARALLEL_CONFIGURE
    PREFER_NINJA
    OPTIONS
        -DMYSQL_INCLUDE_DIR=${MYSQL_INCLUDE_DIR}
    OPTIONS_RELEASE
        -DMYSQL_LIB=${MYSQL_LIB}
    OPTIONS_DEBUG
        -DLIBODB_INSTALL_HEADERS=OFF
        -DMYSQL_LIB=${MYSQL_LIB_DEBUG}
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/odb TARGET_PATH share/odb)

vcpkg_copy_pdbs()

file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
