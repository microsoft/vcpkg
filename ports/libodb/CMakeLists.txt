cmake_minimum_required(VERSION 3.0)
project(libodb VERSION 2.4.0 LANGUAGES CXX)
set(LIBODB_INSTALL_HEADERS:BOOL CACHE OFF)
file(GLOB_RECURSE libodb_src LIST_DIRECTORIES False
    RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
    *.cxx)
list(FILTER libodb_src EXCLUDE REGEX /posix/.*)
add_library(libodb ${libodb_src})
target_include_directories(libodb
    PUBLIC $<INSTALL_INTERFACE:include>
)
if(BUILD_SHARED_LIBS)
    target_compile_definitions(libodb PRIVATE
        -DLIBODB_DYNAMIC_LIB)
else()
    target_compile_definitions(libodb PRIVATE
        -DLIBODB_STATIC_LIB)
endif()
install(TARGETS libodb EXPORT libodbConfig
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
    RUNTIME DESTINATION bin
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
install(EXPORT libodbConfig DESTINATION share/libodb)
export(TARGETS libodb NAMESPACE libodb FILE libodbConfig.cmake)
