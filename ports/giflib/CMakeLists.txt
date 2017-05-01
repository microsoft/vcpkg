cmake_minimum_required(VERSION 3.4)

project(giflib)

set(GIFLIB_HEADERS
    lib/gif_lib.h
)

set(GIFLIB_SOURCES
    lib/dgif_lib.c
    lib/egif_lib.c
    lib/gif_err.c
    lib/gif_font.c
    lib/gif_hash.c
    lib/gifalloc.c
    lib/openbsd-reallocarray.c
    lib/quantize.c
)

add_library(gif ${GIFLIB_SOURCES})
if (BUILD_SHARED_LIBS)
    set_property(TARGET gif PROPERTY WINDOWS_EXPORT_ALL_SYMBOLS ON)
endif ()

if (NOT GIFLIB_SKIP_HEADERS)
    install(FILES ${GIFLIB_HEADERS} DESTINATION include)
endif ()

install(TARGETS gif
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)
