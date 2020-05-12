cmake_minimum_required(VERSION 3.1)
option(USE_SSE       "Use SSE" ON)
project (libspeexdsp)

file(GLOB_RECURSE LIBSPEEXDSP_SOURCES "${CMAKE_CURRENT_LIST_DIR}/libspeexdsp/*.c")
list(FILTER LIBSPEEXDSP_SOURCES EXCLUDE REGEX "${CMAKE_CURRENT_LIST_DIR}/libspeexdsp/test.*\\.c")
file(GLOB_RECURSE LIBSPEEXDSP_HEADERS "${CMAKE_CURRENT_LIST_DIR}/libspeexdsp/*.h")
file(GLOB_RECURSE LIBSPEEXDSP_HEADERS_PUBLIC "${CMAKE_CURRENT_LIST_DIR}/include/**/*.h")

if (BUILD_SHARED_LIBS)
    add_definitions(-D_WINDOWS -D_USRDLL)
    list(APPEND LIBSPEEXDSP_SOURCES "${CMAKE_CURRENT_LIST_DIR}/win32/libspeexdsp.def")
else ()
    add_definitions(-D_LIB)
endif ()

add_definitions(-DHAVE_CONFIG_H -D_WIN32)

if (USE_SSE)
    add_definitions(-D_USE_SSE -D_USE_SSE2)
endif()

include_directories("${CMAKE_CURRENT_LIST_DIR}/include"
                    "${CMAKE_CURRENT_LIST_DIR}/win32")
add_library(libspeexdsp ${LIBSPEEXDSP_SOURCES} ${LIBSPEEXDSP_HEADERS})

set_target_properties(libspeexdsp PROPERTIES PUBLIC_HEADER "${LIBSPEEXDSP_HEADERS_PUBLIC}")

install(TARGETS libspeexdsp
        ARCHIVE DESTINATION "lib"
        RUNTIME DESTINATION "bin"
        PUBLIC_HEADER DESTINATION "include/speex")
