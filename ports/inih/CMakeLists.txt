cmake_minimum_required(VERSION 3.14)
project(iniparser LANGUAGES C CXX)

set(SOURCES ini.c cpp/INIReader.cpp)
set(HEADERS ini.h cpp/INIReader.h)

add_library(inih ${HEADERS} ${SOURCES})

install(
    TARGETS inih
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)

install(FILES ${HEADERS} DESTINATION include)
