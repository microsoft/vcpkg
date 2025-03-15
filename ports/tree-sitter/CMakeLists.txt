cmake_minimum_required(VERSION 3.20)

project(
  tree-sitter
  LANGUAGES C
  VERSION 0.25.1
)

set(TS_SOVERSION_MAJOR 0)
set(TS_SOVERSION_MINOR 0)

include(GNUInstallDirs)

#create parser targets
set(PARSERS @PROTO_PARSERS@)
set(PARSER_TARGETS "")
set(PARSER_PKG_LIBS "")
foreach(PARSER_STRING IN LISTS PARSERS)
  string(REPLACE "|" ";" PARSER "${PARSER_STRING}")
  list(GET PARSER 0 PARSER_NAME)
  list(GET PARSER 1 PARSER_SOURCE_PATH)
  list(GET PARSER 2 PARSER_VERSION)

  set(PARSER_SOURCES "")
  if(EXISTS ${PARSER_SOURCE_PATH}/src/parser.c)
    list(APPEND PARSER_SOURCES ${PARSER_SOURCE_PATH}/src/parser.c)
  endif()
  if(EXISTS ${PARSER_SOURCE_PATH}/src/scanner.c)
    list(APPEND PARSER_SOURCES ${PARSER_SOURCE_PATH}/src/scanner.c)
  endif()
  
  add_library(${PARSER_NAME} ${PARSER_SOURCES})
  list(APPEND PARSER_TARGETS ${PARSER_NAME})

  target_include_directories(
    ${PARSER_NAME}
    PRIVATE $<BUILD_INTERFACE:${PARSER_SOURCE_PATH}/src>
    PUBLIC $<BUILD_INTERFACE:${PARSER_SOURCE_PATH}/include>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>)
  
  set_target_properties(
    ${PARSER_NAME}
    PROPERTIES C_STANDARD 11
               C_STANDARD_REQUIRED ON
               POSITION_INDEPENDENT_CODE ON
               SOVERSION ${TS_SOVERSION_MAJOR}.${TS_SOVERSION_MINOR})

  list(APPEND PARSER_PKG_LIBS "-l${PARSER_NAME}")
endforeach()

file(GLOB TS_SRC_FILES "${PROJECT_SOURCE_DIR}/src/*.c")
list(REMOVE_ITEM TS_SRC_FILES "${PROJECT_SOURCE_DIR}/src/lib.c") # skip amalgamation

add_library(tree-sitter ${TS_SRC_FILES})
target_include_directories(
  tree-sitter
  PRIVATE $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/src>
  PUBLIC $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include>
         $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>)

target_link_libraries(tree-sitter INTERFACE ${PARSER_TARGETS})

set_target_properties(
  tree-sitter
  PROPERTIES C_STANDARD 99
             C_STANDARD_REQUIRED ON
             POSITION_INDEPENDENT_CODE ON
             SOVERSION ${TS_SOVERSION_MAJOR}.${TS_SOVERSION_MINOR})

list(JOIN PARSER_PKG_LIBS " " PARSER_PKG_LIBS)
file(READ "${CMAKE_CURRENT_SOURCE_DIR}/tree-sitter.pc.in" PKG_CONFIG_CONTENT)
string(REPLACE "Libs: -L\${libdir} -ltree-sitter" 
  "Libs: -L\${libdir} -ltree-sitter \@PARSER_PKG_LIBS\@" PKG_CONFIG_CONTENT ${PKG_CONFIG_CONTENT})
set(TEMP_FILE "${CMAKE_BINARY_DIR}/pkgconfig.in")
file(WRITE "${TEMP_FILE}" "${PKG_CONFIG_CONTENT}")
configure_file("${TEMP_FILE}" "${CMAKE_CURRENT_BINARY_DIR}/tree-sitter.pc" @ONLY)
               
install(
  TARGETS tree-sitter ${PARSER_TARGETS}
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
