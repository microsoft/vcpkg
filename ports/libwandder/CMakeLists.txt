cmake_minimum_required(VERSION 3.12)

project(libwandder)

list(APPEND SRCS 
    src/decoder.c
    src/encoder.c
    src/libwandder_etsili.c
    src/itemhandler.c)

list(APPEND HEADERS 
    src/itemhandler.h
    src/libwandder.h
    src/libwandder_etsili.h)
    
add_library(libwandder ${SRCS} ${HEADERS})

include_directories(${CMAKE_CURRENT_SOURCE_DIR}/src/)

install(FILES ${HEADERS} DESTINATION include)

install(TARGETS libwandder
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)