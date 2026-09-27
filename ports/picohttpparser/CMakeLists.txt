cmake_minimum_required(VERSION 3.14)
project(picohttpparser C)

add_library(picohttpparser picohttpparser.c)

target_include_directories(picohttpparser
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
        $<INSTALL_INTERFACE:include>
)

install(TARGETS picohttpparser
    EXPORT unofficial-picohttpparser-config
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
    RUNTIME DESTINATION bin
)

install(FILES picohttpparser.h DESTINATION include)

install(EXPORT unofficial-picohttpparser-config
    FILE unofficial-picohttpparser-config.cmake
    NAMESPACE unofficial::picohttpparser::
    DESTINATION share/unofficial-picohttpparser
)
