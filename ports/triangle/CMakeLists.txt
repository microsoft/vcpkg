cmake_minimum_required(VERSION 3.5...3.30)
project(triangle)

option(BUILD_TOOL "Build the command line tool" OFF)

include(GNUInstallDirs)

add_library(triangle triangle.c exports.def)
set_target_properties(triangle PROPERTIES PUBLIC_HEADER "${CMAKE_SOURCE_DIR}/triangle.h")
target_compile_definitions(triangle PRIVATE -DTRILIBRARY)

add_executable(triangle_exe triangle.c)
set_target_properties(triangle_exe PROPERTIES OUTPUT_NAME "triangle")

foreach(target IN ITEMS triangle triangle_exe)
    target_compile_definitions(${target} PRIVATE -DANSI_DECLARATORS)
    target_include_directories(${target} PUBLIC
        "$<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}>"
        "$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>"
    )
    if(WIN32)
        target_compile_definitions(${target} PRIVATE -DNO_TIMER)
    endif()
    if(UNIX AND NOT APPLE AND NOT ANDROID)
        target_link_libraries(${target} PRIVATE m)
    endif()
endforeach()

install(TARGETS triangle
    EXPORT triangle-targets
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    PUBLIC_HEADER DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
)

install(EXPORT triangle-targets
  FILE unofficial-triangle-config.cmake
  NAMESPACE unofficial::triangle::
  DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}/unofficial-triangle"
)

if(BUILD_TOOL)
    install(TARGETS triangle_exe DESTINATION tools/triangle)
else()
    set_target_properties(triangle_exe PROPERTIES EXCLUDE_FROM_ALL 1)
endif()
