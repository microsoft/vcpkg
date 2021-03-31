cmake_minimum_required(VERSION 3.0)
project(libodb-mysql VERSION 2.4.0 LANGUAGES CXX)
find_package(odb 2.4.0 REQUIRED COMPONENTS libodb)
configure_file(config.unix.h.in
    ${CMAKE_CURRENT_SOURCE_DIR}/odb/mysql/details/config.h COPYONLY)

INCLUDE_DIRECTORIES(${MYSQL_INCLUDE_DIR})
set(LIBODB_INSTALL_HEADERS ON CACHE BOOL "Install the header files (a debug install)")
file(GLOB_RECURSE libodb_src
    RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
    *.cxx)
add_library(libodb-mysql ${libodb_src})
target_include_directories(libodb-mysql
    PUBLIC 
        $<INSTALL_INTERFACE:include>
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>

)

target_link_libraries(libodb-mysql PRIVATE odb::libodb ${MYSQL_LIB})
if(BUILD_SHARED_LIBS)
    target_compile_definitions(libodb-mysql PRIVATE
        -DLIBODB_MYSQL_DYNAMIC_LIB
        -DLIBODB_MYSQL_HAVE_UNLOCK_NOTIFY)
else()
    target_compile_definitions(libodb-mysql PRIVATE
        -DLIBODB_MYSQL_STATIC_LIB
        -DLIBODB_MYSQL_HAVE_UNLOCK_NOTIFY)
endif()
install(TARGETS libodb-mysql EXPORT odb_mysqlConfig
    COMPONENT mysql
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
    RUNTIME DESTINATION bin
)
if(LIBODB_INSTALL_HEADERS)
install(DIRECTORY odb DESTINATION include/
        COMPONENT mysql
        FILES_MATCHING
        PATTERN "*.h"
        PATTERN "*.hxx"
        PATTERN "*.ixx"
        PATTERN "*.txx"
)
endif()
install(EXPORT odb_mysqlConfig NAMESPACE odb:: COMPONENT mysql DESTINATION share/odb)
export(TARGETS libodb-mysql NAMESPACE odb:: FILE odb_mysqlConfig.cmake)