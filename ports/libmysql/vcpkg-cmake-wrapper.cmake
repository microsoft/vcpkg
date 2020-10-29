include(CMakeFindDependencyMacro)
include(SelectLibraryConfigurations)

find_path(MYSQL_INCLUDE_DIR mysql.h PATH_SUFFIXES mysql)
find_library(MYSQL_LIBRARY_DEBUG NAMES libmysql mysqlclient NAMES_PER_DIR PATH_SUFFIXES lib PATHS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug" NO_DEFAULT_PATH)
find_library(MYSQL_LIBRARY_RELEASE NAMES libmysql mysqlclient NAMES_PER_DIR PATH_SUFFIXES lib PATHS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}" NO_DEFAULT_PATH)
select_library_configurations(MYSQL)

if (MYSQL-NOTFOUND)
    message(FATAL_ERROR "Could not found mysql.")
else()
    message(STATUS "Found mysql: ${MYSQL_LIBRARY}")
    set(libmysql_FOUND TRUE)

    find_dependency(OpenSSL)
    find_dependency(ZLIB)
    
    list(APPEND MYSQL_LIBRARY OpenSSL::SSL OpenSSL::Crypto ZLIB::ZLIB)
    
    set(MYSQL_LIBRARIES ${MYSQL_LIBRARY})
    set(MYSQL_INCLUDE_DIRS ${MYSQL_INCLUDE_DIR})
endif()