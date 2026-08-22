cmake_minimum_required(VERSION 3.16)
project(tlsf LANGUAGES C)

add_library(tlsf tlsf.c)

install(
    TARGETS tlsf
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)

install(FILES tlsf.h DESTINATION include)
