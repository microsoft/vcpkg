cmake_minimum_required(VERSION 3.0)
project(libodb-sqlite VERSION 2.4.0 LANGUAGES CXX)
find_package(odb 2.4.0 REQUIRED COMPONENTS libodb)
find_package(unofficial-sqlite3 CONFIG)
configure_file(config.unix.h.in odb/sqlite/details/config.h COPYONLY)

set(LIBODB_INSTALL_HEADERS ON CACHE BOOL "Install the header files (a debug install)")
file(GLOB_RECURSE libodb_src LIST_DIRECTORIES False
    RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
    *.cxx)
list(FILTER libodb_src EXCLUDE REGEX /posix/.*)
add_library(libodb-sqlite ${libodb_src})
target_include_directories(libodb-sqlite
    PUBLIC 
        $<INSTALL_INTERFACE:include>
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
        $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}>
)

target_link_libraries(libodb-sqlite PRIVATE odb::libodb unofficial::sqlite3::sqlite3)
if(BUILD_SHARED_LIBS)
    target_compile_definitions(libodb-sqlite PRIVATE
        -DLIBODB_SQLITE_DYNAMIC_LIB
        -DLIBODB_SQLITE_HAVE_UNLOCK_NOTIFY)
else()
    target_compile_definitions(libodb-sqlite PRIVATE
        -DLIBODB_SQLITE_STATIC_LIB
        -DLIBODB_SQLITE_HAVE_UNLOCK_NOTIFY)
endif()
install(TARGETS libodb-sqlite EXPORT odb_sqliteConfig
    COMPONENT sqlite
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
    RUNTIME DESTINATION bin
)
if(LIBODB_INSTALL_HEADERS)
    install(
        DIRECTORY odb
        DESTINATION include/
        COMPONENT sqlite
        FILES_MATCHING
        PATTERN "*.h"
        PATTERN "*.hxx"
        PATTERN "*.ixx"
        PATTERN "*.txx"
    )
    install(
        FILES config.unix.h.in
        DESTINATION include/odb/sqlite/detail
        COMPONENT sqlite
        RENAME config.h
    )
endif()
install(EXPORT odb_sqliteConfig NAMESPACE odb:: COMPONENT sqlite DESTINATION share/odb)
export(TARGETS libodb-sqlite NAMESPACE odb:: FILE odb_sqliteConfig.cmake)