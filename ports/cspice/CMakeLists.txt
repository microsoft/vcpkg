cmake_minimum_required(VERSION 3.10)
project(cspice LANGUAGES C)

file(GLOB CSPICE_SOURCES "${PROJECT_SOURCE_DIR}/src/cspice/*.c")
set(INCLUDE_PATH "${PROJECT_SOURCE_DIR}/include")

add_library(cspice ${CSPICE_SOURCES})
target_include_directories(cspice PUBLIC
    $<BUILD_INTERFACE:${INCLUDE_PATH}>
    $<INSTALL_INTERFACE:include>
)

# f2c-generated code uses implicit int for functions, which is forbidden in C99.
# Clang (at least) raises an error for this, unless C90 is explicitly selected.
set_target_properties(cspice PROPERTIES C_STANDARD 90)
if(CMAKE_C_COMPILER_ID STREQUAL "Clang" AND CMAKE_C_COMPILER_FRONTEND_VARIANT STREQUAL "MSVC")
    target_compile_options(cspice PRIVATE /clang:-std=gnu90)
endif()

if (WIN32)
    # cf. src/cspice/mkprodct.bat
    target_compile_definitions(cspice PRIVATE "_COMPLEX_DEFINED;MSDOS;OMIT_BLANK_CC;NON_ANSI_STDIO;_CRT_SECURE_NO_WARNINGS")
    set_target_properties(cspice PROPERTIES WINDOWS_EXPORT_ALL_SYMBOLS TRUE)
    if(CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
        target_compile_options(cspice PRIVATE /sdl-)
    endif()
elseif (UNIX)
    target_compile_definitions(cspice PRIVATE "NON_UNIX_STDIO")
    target_compile_options(cspice PRIVATE -Wno-error=implicit-function-declaration)
endif ()

set_target_properties(cspice PROPERTIES
    VERSION "${VERSION}"
    SOVERSION "${VERSION}"
)

file(GLOB SPICE_HEADERS ${INCLUDE_PATH}/*.h)
install(FILES ${SPICE_HEADERS} DESTINATION include/cspice)

install(
    TARGETS cspice
    EXPORT cspice
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
    RUNTIME DESTINATION bin
)

install(
    EXPORT cspice
    FILE unofficial-cspice-config.cmake
    NAMESPACE unofficial::cspice::
    DESTINATION share/unofficial-cspice
)
