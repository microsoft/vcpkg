cmake_minimum_required(VERSION 2.8.12)
project(triangle)

include(GNUInstallDirs)

add_library(triangleLib triangle.c exports.def)
add_executable(triangle triangle.c)

target_compile_definitions(triangleLib PRIVATE -DTRILIBRARY -DANSI_DECLARATORS)
target_compile_definitions(triangle PRIVATE -DANSI_DECLARATORS)
if(WIN32)
   target_compile_definitions(triangleLib PRIVATE -DNO_TIMER)
   target_compile_definitions(triangle PRIVATE -DNO_TIMER)
endif()

if (${CMAKE_SYSTEM_NAME} MATCHES "Linux")
    target_link_libraries(triangle m)
endif()

target_include_directories(triangleLib PUBLIC
    $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}>
)

set_target_properties(triangleLib PROPERTIES POSITION_INDEPENDENT_CODE ON)

set_target_properties(triangleLib PROPERTIES PUBLIC_HEADER
    "${CMAKE_SOURCE_DIR}/triangle.h"
)

set_target_properties(triangleLib PROPERTIES OUTPUT_NAME "triangle")

install(TARGETS triangleLib EXPORT triangleTargets
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    PUBLIC_HEADER DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
)

install(TARGETS triangle DESTINATION tools/triangle)

install(EXPORT triangleTargets
  FILE triangleConfig.cmake
  NAMESPACE triangle::
  DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}/triangle"
)
