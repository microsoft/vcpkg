cmake_minimum_required(VERSION 3.0)
project(libodb VERSION 2.4.0 LANGUAGES CXX)
set(LIBODB_INSTALL_HEADERS ON CACHE BOOL "Install the header files (a debug install)")
configure_file(config.unix.h.in
    ${CMAKE_CURRENT_SOURCE_DIR}/odb/details/config.h COPYONLY)

file(GLOB_RECURSE libodb_src LIST_DIRECTORIES False
    RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
    *.cxx)
if (WIN32)
  list(FILTER libodb_src EXCLUDE REGEX /posix/.*)
elseif (UNIX)
  list(FILTER libodb_src EXCLUDE REGEX /win32/.*)
endif()

add_library(libodb ${libodb_src})
target_include_directories(libodb
    PUBLIC
        $<INSTALL_INTERFACE:include>
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>

)
if(BUILD_SHARED_LIBS)
    target_compile_definitions(libodb PRIVATE
        -DLIBODB_DYNAMIC_LIB)
else()
    target_compile_definitions(libodb PRIVATE
        -DLIBODB_STATIC_LIB)
endif()
install(TARGETS libodb EXPORT odb_libodbConfig
    COMPONENT libodb
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
    RUNTIME DESTINATION bin
)
if(LIBODB_INSTALL_HEADERS)
install(DIRECTORY odb DESTINATION include/
        COMPONENT libodb
        FILES_MATCHING
        PATTERN "*.h"
        PATTERN "*.hxx"
        PATTERN "*.ixx"
        PATTERN "*.txx"
)
endif()
install(EXPORT odb_libodbConfig NAMESPACE odb:: COMPONENT libodb DESTINATION share/odb)
export(TARGETS libodb NAMESPACE odb:: FILE odb_libodbConfig.cmake)
