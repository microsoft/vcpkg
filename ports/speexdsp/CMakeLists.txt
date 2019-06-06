# CMAKE project for libspeexdsp
cmake_minimum_required(VERSION 3.1)
option(SOURCE_PATH   "Root directory.")
option(USE_SSE       "Use SSE")
project (libspeexdsp)

file(GLOB_RECURSE LIBSPEEXDSP_SOURCES "${SOURCE_PATH}/libspeexdsp/*.c")
list(REMOVE_ITEM LIBSPEEXDSP_SOURCES "${SOURCE_PATH}/libspeexdsp/testdenoise.c"
                                     "${SOURCE_PATH}/libspeexdsp/testecho.c"
                                     "${SOURCE_PATH}/libspeexdsp/testjitter.c"
                                     "${SOURCE_PATH}/libspeexdsp/testresample.c")
file(GLOB_RECURSE LIBSPEEXDSP_HEADERS "${SOURCE_PATH}/libspeexdsp/*.h")
file(GLOB_RECURSE LIBSPEEXDSP_HEADERS_PUBLIC "${SOURCE_PATH}/include/**/*.h")

if (BUILD_SHARED_LIBS)
    add_definitions(-D_WINDOWS -D_USRDLL)
    list(APPEND LIBSPEEXDSP_SOURCES "${SOURCE_PATH}/win32/libspeexdsp.def")
else ()
    add_definitions(-D_LIB)
endif ()

add_definitions(-DHAVE_CONFIG_H -D_WIN32)

if (USE_SSE)
    add_definitions(-D_USE_SSE -D_USE_SSE2)
endif()

include_directories("${SOURCE_PATH}/include"
                    "${SOURCE_PATH}/win32")
add_library(libspeexdsp ${LIBSPEEXDSP_SOURCES} ${LIBSPEEXDSP_HEADERS})

set_target_properties(libspeexdsp PROPERTIES PUBLIC_HEADER "${LIBSPEEXDSP_HEADERS_PUBLIC}")

install(TARGETS libspeexdsp
        ARCHIVE DESTINATION "lib"
        RUNTIME DESTINATION "bin"
        PUBLIC_HEADER DESTINATION "include/speex")
