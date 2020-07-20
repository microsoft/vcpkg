cmake_minimum_required(VERSION 3.2)
project(irrXML)
enable_language(CXX)

set(INSTALL_BIN_DIR      "bin"                      CACHE PATH "Path where exe and dll will be installed")
set(INSTALL_LIB_DIR      "lib"                      CACHE PATH "Path where lib will be installed")
set(INSTALL_INCLUDE_DIR  "include"                  CACHE PATH "Path where headers will be installed")
set(INSTALL_CMAKE_DIR    "share/irrxml"             CACHE PATH "Path where cmake configs will be installed")

# Make relative paths absolute (needed later on)
set(RELATIVE_INSTALL_INCLUDE_DIR ${INSTALL_INCLUDE_DIR})
foreach(p LIB BIN INCLUDE CMAKE)
  set(var INSTALL_${p}_DIR)
  if(NOT IS_ABSOLUTE "${${var}}")
    set(${var} "${CMAKE_INSTALL_PREFIX}/${${var}}")
  endif()
endforeach()

set(SOURCES
    ${CMAKE_CURRENT_LIST_DIR}/src/CXMLReaderImpl.h
    ${CMAKE_CURRENT_LIST_DIR}/src/fast_atof.h
    ${CMAKE_CURRENT_LIST_DIR}/src/heapsort.h
    ${CMAKE_CURRENT_LIST_DIR}/src/irrArray.h
    ${CMAKE_CURRENT_LIST_DIR}/src/irrString.h
    ${CMAKE_CURRENT_LIST_DIR}/src/irrTypes.h
    ${CMAKE_CURRENT_LIST_DIR}/src/irrXML.cpp
    ${CMAKE_CURRENT_LIST_DIR}/src/irrXML.h
)

add_library(${CMAKE_PROJECT_NAME} ${SOURCES})

if(MSVC)
  target_compile_definitions(${CMAKE_PROJECT_NAME} PRIVATE _SCL_SECURE_NO_WARNINGS)
  target_compile_definitions(${CMAKE_PROJECT_NAME} PRIVATE _CRT_SECURE_NO_WARNINGS)
endif(MSVC)

if (WIN32 AND BUILD_SHARED_LIBS)
    set_target_properties(${CMAKE_PROJECT_NAME} PROPERTIES WINDOWS_EXPORT_ALL_SYMBOLS ON)
endif()

set_target_properties(${CMAKE_PROJECT_NAME} PROPERTIES PUBLIC_HEADER src/irrXML.h)
target_include_directories(${CMAKE_PROJECT_NAME} PUBLIC $<INSTALL_INTERFACE:${RELATIVE_INSTALL_INCLUDE_DIR}> $<BUILD_INTERFACE:${CMAKE_CURRENT_LIST_DIR}/src>)

install(TARGETS ${CMAKE_PROJECT_NAME} EXPORT ${CMAKE_PROJECT_NAME}Targets
  RUNTIME DESTINATION "${INSTALL_BIN_DIR}"
  LIBRARY DESTINATION "${INSTALL_LIB_DIR}"
  ARCHIVE DESTINATION "${INSTALL_LIB_DIR}"
  PUBLIC_HEADER DESTINATION "${INSTALL_INCLUDE_DIR}"
  COMPONENT dev
)

install(EXPORT ${CMAKE_PROJECT_NAME}Targets
  FILE ${CMAKE_PROJECT_NAME}Config.cmake
  NAMESPACE ${CMAKE_PROJECT_NAME}::
  DESTINATION "${INSTALL_CMAKE_DIR}"
)
