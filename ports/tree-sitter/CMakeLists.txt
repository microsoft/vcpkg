cmake_minimum_required(VERSION 3.20)

project(
  tree-sitter
  LANGUAGES C
  VERSION 0.25.1
)

set(TS_SOVERSION_MAJOR 0)
set(TS_SOVERSION_MINOR 0)

file(GLOB TS_SRC_FILES "${PROJECT_SOURCE_DIR}/src/*.c")
list(REMOVE_ITEM TS_SRC_FILES "${PROJECT_SOURCE_DIR}/src/lib.c") # skip amalgamation

include(GNUInstallDirs)

add_library(tree-sitter ${TS_SRC_FILES})
target_include_directories(
  tree-sitter
  PRIVATE $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/src>
  PUBLIC $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include>
         $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>)

set_target_properties(
  tree-sitter
  PROPERTIES C_STANDARD 99
             C_STANDARD_REQUIRED ON
             POSITION_INDEPENDENT_CODE ON
             SOVERSION ${TS_SOVERSION_MAJOR}.${TS_SOVERSION_MINOR})

configure_file("${CMAKE_CURRENT_SOURCE_DIR}/tree-sitter.pc.in"
               "${CMAKE_CURRENT_BINARY_DIR}/tree-sitter.pc" @ONLY)

install(
  TARGETS tree-sitter
  EXPORT unofficial-tree-sitter-config
  LIBRARY DESTINATION "${CMAKE_INSTALL_LIBDIR}"
  RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}"
  ARCHIVE DESTINATION "${CMAKE_INSTALL_LIBDIR}")

install(FILES "${PROJECT_SOURCE_DIR}/include/tree_sitter/api.h"
        DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}/tree_sitter")

install(
  EXPORT unofficial-tree-sitter-config
  NAMESPACE unofficial::tree-sitter::
  DESTINATION share/unofficial-tree-sitter)

install(FILES "${CMAKE_CURRENT_BINARY_DIR}/tree-sitter.pc"
        DESTINATION "${CMAKE_INSTALL_LIBDIR}/pkgconfig")
