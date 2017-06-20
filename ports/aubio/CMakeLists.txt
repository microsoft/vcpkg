cmake_minimum_required(VERSION 3.8)
project(aubio C)

add_definitions(
    -DHAVE_STDLIB_H=1
    -DHAVE_STDIO_H=1
    -DHAVE_MATH_H=1
    -DHAVE_STRING_H=1
    -DHAVE_LIMITS_H=1
    -DHAVE_STDARG_H=1
    -DHAVE_C99_VARARGS_MACROS=1

    -DHAVE_SNDFILE=1
    -DHAVE_WAVWRITE=1
    -DHAVE_WAVREAD=1
    -DHAVE_LIBAV=1
    -DHAVE_SWRESAMPLE=1
)

set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON)

find_path(LIBSNDFILE_H sndfile.h)
find_library(LIBSNDFILE_LIB NAMES libsndfile-1 libsndfile)
find_library(AVCODEC_LIB avcodec)
find_library(AVUTIL_LIB avutil)
find_library(AVDEVICE_LIB avdevice)
find_library(AVFILTER_LIB avfilter)
find_library(AVFORMAT_LIB avformat)
find_library(SWRESAMPLE_LIB swresample)

include_directories(src ${LIBSNDFILE_H})
link_libraries(${LIBSNDFILE_LIB} ${AVCODEC_LIB} ${AVUTIL_LIB} ${AVDEVICE_LIB} ${AVFILTER_LIB} ${AVFORMAT_LIB} ${SWRESAMPLE_LIB} ws2_32.lib)

file(GLOB_RECURSE SOURCES src/*.c)
set_source_files_properties(src/io/sink_wavwrite.c PROPERTIES COMPILE_FLAGS /FIWinsock2.h)
add_library(aubio ${SOURCES})

set(CMAKE_DEBUG_POSTFIX d)

install(
    TARGETS aubio
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)

if(NOT DISABLE_INSTALL_HEADERS)
    install(
        DIRECTORY src/
        DESTINATION include/aubio
        FILES_MATCHING
        PATTERN "*.h"
        PATTERN "*_priv.h" EXCLUDE
        PATTERN "config.h" EXCLUDE
    )
endif()
