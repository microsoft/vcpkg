cmake_minimum_required(VERSION 3.1.0)
project(id3tag VERSION 0.15.1)

option(BUILD_SHARED_LIBS "Build dynamic library" ON)

include(GNUInstallDirs)

#
# Build
#

add_library(id3tag
    compat.c
    crc.c
    debug.c
    field.c
    file.c
    frame.c
    frametype.c
    genre.c
    latin1.c
    parse.c
    render.c
    tag.c
    ucs4.c
    utf16.c
    utf8.c
    util.c
    version.c
)
target_include_directories(id3tag PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)
if(WIN32 AND BUILD_SHARED_LIBS)
    set_target_properties(id3tag PROPERTIES WINDOWS_EXPORT_ALL_SYMBOLS ON)
endif()

find_package(ZLIB REQUIRED)
target_link_libraries(id3tag PRIVATE ZLIB::ZLIB)

#
# Installation
#

include(CMakePackageConfigHelpers)

# Library files
install(TARGETS id3tag
  EXPORT id3tagTargets
  ARCHIVE DESTINATION "${CMAKE_INSTALL_LIBDIR}"
  LIBRARY DESTINATION "${CMAKE_INSTALL_LIBDIR}"
  RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}"
  INCLUDES DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}"
)

# Header files
install(
  FILES "${CMAKE_CURRENT_SOURCE_DIR}/id3tag.h"
  DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}"
)

# CMake config
set(ID3TAG_INSTALL_CMAKEDIR "lib/cmake/id3tag")
install(
  EXPORT id3tagTargets
  FILE id3tagTargets.cmake
  NAMESPACE id3tag::
  DESTINATION "${ID3TAG_INSTALL_CMAKEDIR}"
)
configure_package_config_file(id3tagConfig.cmake.in
  "${CMAKE_CURRENT_BINARY_DIR}/id3tagConfig.cmake"
  INSTALL_DESTINATION "${ID3TAG_INSTALL_CMAKEDIR}"
)
write_basic_package_version_file(
  "${CMAKE_CURRENT_BINARY_DIR}/id3tagConfigVersion.cmake"
  VERSION "${CMAKE_PROJECT_VERSION}"
  COMPATIBILITY SameMajorVersion
)
install(
  FILES
    "${CMAKE_CURRENT_BINARY_DIR}/id3tagConfig.cmake"
    "${CMAKE_CURRENT_BINARY_DIR}/id3tagConfigVersion.cmake"
  DESTINATION "${ID3TAG_INSTALL_CMAKEDIR}"
)
