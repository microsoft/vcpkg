cmake_minimum_required(VERSION 3.1)
project(cspice
    VERSION 67
    DESCRIPTION "The NAIF SPICE Toolkit (C version)"
    HOMEPAGE_URL "https://naif.jpl.nasa.gov/naif/toolkit.html"
    LANGUAGES C
)

set(SOVERSION ${PROJECT_VERSION})

include(GNUInstallDirs)

# Include all *.c files from the library
file(GLOB CSPICE_SOURCE ${PROJECT_SOURCE_DIR}/cspice/src/cspice/*.c)
set(INCLUDE_PATH "${PROJECT_SOURCE_DIR}/cspice/include")

add_library(cspice ${CSPICE_SOURCE})
target_include_directories(cspice PRIVATE "${INCLUDE_PATH}")

if (WIN32)
    target_compile_definitions(cspice PRIVATE "_COMPLEX_DEFINED;MSDOS;OMIT_BLANK_CC;NON_ANSI_STDIO;_CRT_SECURE_NO_WARNINGS")
    set_target_properties(cspice PROPERTIES WINDOWS_EXPORT_ALL_SYMBOLS TRUE)
elseif (UNIX)
    target_compile_definitions(cspice PRIVATE "NON_UNIX_STDIO")
    if(CMAKE_SIZEOF_VOID_P EQUAL 8)
        target_compile_options(cspice PRIVATE -m64 -ansi)
    elseif(CMAKE_SIZEOF_VOID_P EQUAL 4)
        target_compile_options(cspice PRIVATE -m32 -ansi) 
    endif()
    target_compile_options(cspice PRIVATE -Wno-error=implicit-function-declaration)
endif ()

if (NOT _SKIP_HEADERS)
    file(GLOB SPICE_HEADERS ${INCLUDE_PATH}/*.h)
    install(FILES ${SPICE_HEADERS} DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/cspice)
endif()

set_target_properties(cspice PROPERTIES
    VERSION ${PROJECT_VERSION}
    SOVERSION ${SOVERSION}
    POSITION_INDEPENDENT_CODE ON
)

install(
    TARGETS cspice
    EXPORT cspice
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
    RUNTIME DESTINATION bin
)
