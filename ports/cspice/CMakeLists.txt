cmake_minimum_required(VERSION 3.1)
project(cspice LANGUAGES C)

set(SOVERSION 66)

# Include all *.c files from the library
file(GLOB CSPICE_SOURCE ${PROJECT_SOURCE_DIR}/cspice/src/cspice/*.c)
set(INCLUDE_PATH "${PROJECT_SOURCE_DIR}/cspice/include")

if (_STATIC_BUILD)
    add_library(cspice STATIC ${CSPICE_SOURCE})
else()
    add_library(cspice SHARED ${CSPICE_SOURCE})
endif()
target_include_directories(cspice PUBLIC "${INCLUDE_PATH}")

if (WIN32)
    target_compile_definitions(cspice PUBLIC "_COMPLEX_DEFINED;MSDOS;OMIT_BLANK_CC;NON_ANSI_STDIO;_CRT_SECURE_NO_WARNINGS")
    set_target_properties(cspice PROPERTIES WINDOWS_EXPORT_ALL_SYMBOLS TRUE)
elseif (UNIX)
    target_compile_definitions(cspice PUBLIC "NON_UNIX_STDIO")
    if(CMAKE_SIZEOF_VOID_P EQUAL 8)
        target_compile_options(cspice PUBLIC -m64 -ansi -fPIC)
    elseif(CMAKE_SIZEOF_VOID_P EQUAL 4)
        target_compile_options(cspice PUBLIC -m32 -ansi -fPIC) 
    endif()
    target_compile_options(cspice PRIVATE -Wno-error=implicit-function-declaration)
endif ()

if (NOT _SKIP_HEADERS)
    file(GLOB SPICE_HEADERS ${INCLUDE_PATH}/*.h)
    install(FILES ${SPICE_HEADERS} DESTINATION include)
endif()

set_target_properties(
    cspice
    PROPERTIES SOVERSION ${SOVERSION}
)

install(
    TARGETS cspice
    EXPORT cspice
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
    RUNTIME DESTINATION bin
)
