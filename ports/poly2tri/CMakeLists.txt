cmake_minimum_required(VERSION 3.0)

if(POLICY CMP0063)
  cmake_policy(SET CMP0063 NEW)
endif()

set(CMAKE_CXX_VISIBILITY_PRESET hidden)
set(CMAKE_VISIBILITY_INLINES_HIDDEN TRUE)

project(poly2tri LANGUAGES C CXX)

set(INSTALL_BIN_DIR      "bin"                     CACHE PATH "Path where exe and dll will be installed")
set(INSTALL_LIB_DIR      "lib"                     CACHE PATH "Path where lib will be installed")
set(INSTALL_INCLUDE_DIR  "include/${PROJECT_NAME}" CACHE PATH "Path where headers will be installed")
set(INSTALL_CMAKE_DIR    "share/${PROJECT_NAME}"   CACHE PATH "Path where cmake configs will be installed")

set(${PROJECT_NAME}_HEADERS
    "poly2tri/poly2tri.h"
)

set(${PROJECT_NAME}_COMMON_HEADERS
    "poly2tri/common/shapes.h"
    "poly2tri/common/utils.h"
)

set(${PROJECT_NAME}_SWEEP_HEADERS
    "poly2tri/sweep/advancing_front.h"
    "poly2tri/sweep/cdt.h"
    "poly2tri/sweep/sweep.h"
    "poly2tri/sweep/sweep_context.h"
)

set(${PROJECT_NAME}_SOURCES
    "poly2tri/common/shapes.cc"
    "poly2tri/sweep/advancing_front.cc"
    "poly2tri/sweep/cdt.cc"
    "poly2tri/sweep/sweep.cc"
    "poly2tri/sweep/sweep_context.cc"
)

add_library(${PROJECT_NAME} "${${PROJECT_NAME}_HEADERS}" "${${PROJECT_NAME}_COMMON_HEADERS}" "${${PROJECT_NAME}_SWEEP_HEADERS}" "${${PROJECT_NAME}_SOURCES}")
set_target_properties(${PROJECT_NAME} PROPERTIES PUBLIC_HEADER "${${PROJECT_NAME}_HEADERS}")
target_include_directories(${PROJECT_NAME} PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/poly2tri>
    $<INSTALL_INTERFACE:include>
    $<INSTALL_INTERFACE:include/${PROJECT_NAME}>
)

install(FILES ${${PROJECT_NAME}_COMMON_HEADERS} DESTINATION "${INSTALL_INCLUDE_DIR}/common")
install(FILES ${${PROJECT_NAME}_SWEEP_HEADERS} DESTINATION "${INSTALL_INCLUDE_DIR}/sweep")

install(TARGETS ${PROJECT_NAME} EXPORT ${PROJECT_NAME}Targets
  RUNTIME DESTINATION "${INSTALL_BIN_DIR}"
  LIBRARY DESTINATION "${INSTALL_LIB_DIR}"
  ARCHIVE DESTINATION "${INSTALL_LIB_DIR}"
  PUBLIC_HEADER DESTINATION "${INSTALL_INCLUDE_DIR}"
  COMPONENT dev
)

install (EXPORT ${PROJECT_NAME}Targets
    FILE ${PROJECT_NAME}Config.cmake
    NAMESPACE ${PROJECT_NAME}::
    DESTINATION "${INSTALL_CMAKE_DIR}"
)
