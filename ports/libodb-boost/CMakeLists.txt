cmake_minimum_required(VERSION 3.0)
project(libodb-boost VERSION 2.4.0 LANGUAGES CXX)
find_package(odb 2.4.0 REQUIRED COMPONENTS libodb)
configure_file(config.unix.h.in
    ${CMAKE_CURRENT_SOURCE_DIR}/odb/boost/details/config.h COPYONLY)

# FIXME: should we require boost? which packages?
# find_package(PostgreSQL REQUIRED)
set(LIBODB_INSTALL_HEADERS ON CACHE BOOL "Install the header files (a debug install)")
file(GLOB_RECURSE libodb_src LIST_DIRECTORIES False
    RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
    *.cxx)
add_library(libodb-boost ${libodb_src})
target_include_directories(libodb-boost
    PUBLIC
        $<INSTALL_INTERFACE:include>
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>

)

target_link_libraries(libodb-boost PRIVATE odb::libodb)
if(BUILD_SHARED_LIBS)
    target_compile_definitions(libodb-boost PRIVATE
        -DLIBODB_BOOST_DYNAMIC_LIB)
else()
    target_compile_definitions(libodb-boost PRIVATE
        -DLIBODB_BOOST_STATIC_LIB)
endif()
install(TARGETS libodb-boost EXPORT odb_boostConfig
    COMPONENT boost
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
        PATTERN "*.options"
)
endif()
install(EXPORT odb_boostConfig NAMESPACE odb:: COMPONENT boost DESTINATION share/odb)
export(TARGETS libodb-boost NAMESPACE odb:: FILE odb_boostConfig.cmake)
