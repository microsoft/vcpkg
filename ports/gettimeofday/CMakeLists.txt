cmake_minimum_required(VERSION 3.8)
project(gettimeofday C)

add_library(gettimeofday gettimeofday.c gettimeofday.def)

install(TARGETS gettimeofday
    RUNTIME DESTINATION bin
    ARCHIVE DESTINATION lib/manual-link
    LIBRARY DESTINATION lib/manual-link
)

if(CMAKE_BUILD_TYPE STREQUAL "Release")
    install(FILES gettimeofday.h DESTINATION include)
endif()
