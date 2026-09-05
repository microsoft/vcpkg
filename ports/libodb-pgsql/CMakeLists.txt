cmake_minimum_required(VERSION 3.0)
project(libodb-pgsql VERSION 2.4.0 LANGUAGES CXX)
set(CMAKE_CXX_STANDARD 11) # 17 removes 'auto_ptr'
find_package(odb 2.4.0 REQUIRED COMPONENTS libodb)
find_package(PostgreSQL REQUIRED)
configure_file(config.unix.h.in
    ${CMAKE_CURRENT_SOURCE_DIR}/odb/pgsql/details/config.h COPYONLY)

set(LIBODB_INSTALL_HEADERS ON CACHE BOOL "Install the header files (a debug install)")
file(GLOB_RECURSE libodb_src LIST_DIRECTORIES False
    RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
    *.cxx)
list(FILTER libodb_src EXCLUDE REGEX /posix/.*)
add_library(libodb-pgsql ${libodb_src})
target_include_directories(libodb-pgsql
    PUBLIC 
        $<INSTALL_INTERFACE:include>
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>

)

target_link_libraries(libodb-pgsql PRIVATE odb::libodb ${PostgreSQL_LIBRARY})
if(BUILD_SHARED_LIBS)
    target_compile_definitions(libodb-pgsql PRIVATE
        -DLIBODB_PGSQL_DYNAMIC_LIB)
else()
    target_compile_definitions(libodb-pgsql PRIVATE
        -DLIBODB_PGSQL_STATIC_LIB)
endif()
install(TARGETS libodb-pgsql EXPORT odb_pgsqlConfig
    COMPONENT pgsql
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
    RUNTIME DESTINATION bin
)
if(LIBODB_INSTALL_HEADERS)
install(DIRECTORY odb DESTINATION include/
        COMPONENT sqlite
        FILES_MATCHING
        PATTERN "*.h"
        PATTERN "*.hxx"
        PATTERN "*.ixx"
        PATTERN "*.txx"
)
endif()
install(EXPORT odb_pgsqlConfig NAMESPACE odb:: COMPONENT pgsql DESTINATION share/odb)
export(TARGETS libodb-pgsql NAMESPACE odb:: FILE odb_pgsqlConfig.cmake)