cmake_minimum_required(VERSION 3.0)
project(lz4 C)

if(MSVC AND BUILD_SHARED_LIBS)
    add_definitions(-DLZ4_DLL_EXPORT)
endif()
add_definitions(-DXXH_NAMESPACE=LZ4_)

set(CMAKE_INSTALL_PREFIX "${CMAKE_CURRENT_LIST_DIR}" CACHE PATH "Install prefix")
set(INSTALL_BIN_DIR      "bin"                       CACHE PATH "Path where exe and dll will be installed")
set(INSTALL_LIB_DIR      "lib"                       CACHE PATH "Path where lib will be installed")
set(INSTALL_INCLUDE_DIR  "include"                   CACHE PATH "Path where headers will be installed")
set(INSTALL_CMAKE_DIR    "share/lz4"                 CACHE PATH "Path where cmake configs will be installed")

file(GLOB LZ4_HEADERS lib/*.h)
list(REMOVE_ITEM LZ4_HEADERS "${CMAKE_CURRENT_LIST_DIR}/lib/xxhash.h")

add_library(lz4
    ${LZ4_HEADERS}
    lib/lz4.c
    lib/lz4frame.c
    lib/lz4hc.c
    lib/xxhash.c
)

target_include_directories(lz4 PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_LIST_DIR}/lib> $<INSTALL_INTERFACE:include>)
set_target_properties(lz4 PROPERTIES PUBLIC_HEADER "${LZ4_HEADERS}")

install(TARGETS lz4
    EXPORT lz4Config
    RUNTIME DESTINATION "${INSTALL_BIN_DIR}"
    ARCHIVE DESTINATION "${INSTALL_LIB_DIR}"
    LIBRARY DESTINATION "${INSTALL_LIB_DIR}"
    PUBLIC_HEADER DESTINATION "${INSTALL_INCLUDE_DIR}"
    PRIVATE_HEADER DESTINATION "${INSTALL_INCLUDE_DIR}"
    COMPONENT dev
)

FILE(GLOB lz4h "${CMAKE_CURRENT_LIST_DIR}/lib/*.h")
list(REMOVE_ITEM lz4h "${CMAKE_CURRENT_LIST_DIR}/lib/xxhash.h")
INSTALL(FILES ${lz4h} DESTINATION "${INSTALL_INCLUDE_DIR}")

install(EXPORT lz4Config
  FILE lz4-config.cmake
  NAMESPACE lz4::
  DESTINATION "${INSTALL_CMAKE_DIR}"
)

# Export the package for use from the build-tree (this registers the build-tree with a global CMake-registry)
export(PACKAGE lz4)

# Create pkgconfig module file
file(STRINGS "lib/lz4.h" LZ4_H REGEX "^#define LZ4_VERSION_(MAJOR|MINOR|RELEASE) ")
string(REGEX REPLACE "^.*MAJOR +([0-9]+).*MINOR +([0-9]+).*RELEASE +([0-9]+).*$" "\\1.\\2.\\3" VERSION "${LZ4_H}")
set(INCLUDEDIR [[${prefix}/include]])
set(LIBDIR [[${prefix}/lib]])
configure_file(lib/liblz4.pc.in lib/liblz4.pc @ONLY)
install(FILES "${CMAKE_CURRENT_BINARY_DIR}/lib/liblz4.pc" DESTINATION "lib/pkgconfig")
