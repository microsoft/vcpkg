cmake_minimum_required(VERSION 3.4)
project(libjbig C)

set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON)

set(SOURCES
    "libjbig/jbig.c"
    "libjbig/jbig_ar.c"
    "libjbig/jbig85.c")

set(HEADERS
    "libjbig/jbig.h"
    "libjbig/jbig_ar.h"
    "libjbig/jbig85.h"
)

add_library(libjbig ${SOURCES})

install(
    TARGETS libjbig
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)

install(
    FILES ${HEADERS}
    DESTINATION include)
