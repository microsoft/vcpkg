cmake_minimum_required (VERSION 3.14)
project ("rply")
set (target_name ${CMAKE_PROJECT_NAME})
set (target_include_prefix "rply")

option (BUILD_SHARED_LIBS "Create ${target_name} as a shared library" ON)

set (CMAKE_DEBUG_POSTFIX "d" CACHE STRING "postfix for debug lib")

include (GNUInstallDirs)

file (GLOB target_headers "*.h")
file (GLOB target_srcs "*.c" )
add_library (${target_name} ${target_srcs} ${target_headers})

target_include_directories (${target_name}
    PUBLIC $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)

if (MSVC)
    target_compile_definitions (${target_name} PRIVATE RPLY_BUILD_LIB)
endif ()

if (BUILD_SHARED_LIBS)
    target_compile_definitions (${target_name} PUBLIC RPLY_SHARED_LIB)
endif ()

set_target_properties(${target_name} PROPERTIES
    C_STANDARD 11
)

if (MSVC)
    set_target_properties(${target_name} PROPERTIES
        VS_DEBUGGER_WORKING_DIRECTORY $<TARGET_FILE_DIR:${target_name}>
    )
    set_property(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} PROPERTY VS_STARTUP_PROJECT ${target_name})
endif()

message (STATUS "CMAKE_INSTALL_PREFIX = ${CMAKE_INSTALL_PREFIX}")

install (TARGETS ${target_name} EXPORT ${target_name}-targets
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

install (FILES ${target_headers}
    DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}/${target_name}"
    CONFIGURATIONS Release
)

install (EXPORT ${target_name}-targets
    FILE ${target_name}-targets.cmake
    NAMESPACE ${target_name}::
    DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}/${target_name}"
)

configure_file(${target_name}-config.cmake.in "${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/${target_name}-config.cmake" @ONLY)

install(FILES
  "${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/${target_name}-config.cmake"
  DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}/${target_name}"
)
