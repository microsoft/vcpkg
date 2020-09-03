cmake_minimum_required(VERSION 2.8.12)
project(triangle)

include(GNUInstallDirs)

add_library(triangle triangle.c exports.def)
target_compile_definitions(triangle PRIVATE -DTRILIBRARY -DANSI_DECLARATORS)
if(WIN32)
   target_compile_definitions(triangle PRIVATE -DNO_TIMER)
endif()

target_include_directories(triangle PUBLIC
    $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}>
)

set_target_properties(triangle PROPERTIES POSITION_INDEPENDENT_CODE ON)

set_target_properties(triangle PROPERTIES PUBLIC_HEADER
    "${CMAKE_SOURCE_DIR}/triangle.h"
)

install(TARGETS triangle EXPORT triangleTargets
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    PUBLIC_HEADER DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
)

install(EXPORT triangleTargets
  FILE triangleConfig.cmake
  NAMESPACE triangle::
  DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}/triangle"
)