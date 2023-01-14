cmake_minimum_required(VERSION 3.4)

project(giflib C)

set(GIFLIB_EXPORTS "NOTFOUND" CACHE FILEPATH "The path of the DEF file listing the DLL exports.")

set(GIFLIB_HEADERS
    gif_lib.h
)

set(GIFLIB_SOURCES
    dgif_lib.c
    egif_lib.c
    gifalloc.c
    gif_err.c
    gif_font.c
    gif_hash.c
    openbsd-reallocarray.c
)

add_definitions(-D_CRT_SECURE_NO_WARNINGS)

include(CheckSymbolExists)
check_symbol_exists(reallocarray "stdlib.h" HAVE_REALLOCARRAY)
if(HAVE_REALLOCARRAY)
	add_definitions(-DHAVE_REALLOCARRAY)
endif()

add_library(gif ${GIFLIB_SOURCES})
if(BUILD_SHARED_LIBS AND WIN32)
    target_sources(gif PRIVATE "${GIFLIB_EXPORTS}")
else()
    set(UNUSED "${GIFLIB_EXPORTS}")
endif()

if (NOT GIFLIB_SKIP_HEADERS)
    install(FILES ${GIFLIB_HEADERS} DESTINATION include)
endif ()

install(TARGETS gif
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)
