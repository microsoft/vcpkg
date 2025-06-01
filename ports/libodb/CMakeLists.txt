cmake_minimum_required(VERSION 3.8)
project(libodb VERSION 2.5.0 LANGUAGES CXX)
set(LIBODB_INSTALL_HEADERS ON CACHE BOOL "Install the header files (a debug install)")

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
target_compile_definitions(libodb PRIVATE -DLIBODB_BUILD2)
if(BUILD_SHARED_LIBS)
    target_compile_definitions(libodb PRIVATE -DLIBODB_SHARED_BUILD)
else()
    target_compile_definitions(libodb PRIVATE -DLIBODB_STATIC_BUILD)
endif()

install(TARGETS libodb EXPORT unofficial-libodb-config
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
    RUNTIME DESTINATION bin
)

install(EXPORT unofficial-libodb-config
    FILE unofficial-libodb-config.cmake
    NAMESPACE unofficial::libodb::
    DESTINATION share/unofficial-libodb
)

if(LIBODB_INSTALL_HEADERS)
install(DIRECTORY odb DESTINATION include/
        FILES_MATCHING
        PATTERN "*.h"
        PATTERN "*.hxx"
        PATTERN "*.ixx"
        PATTERN "*.txx"
)
endif()
