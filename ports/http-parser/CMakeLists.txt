cmake_minimum_required (VERSION 2.6)
project (http-parser)

set(PUBLIC_HDRS
    http_parser.h
)
set(PRIVATE_HDRS
)
set(SRCS
    http_parser.c
)

add_library(http_parser STATIC ${SRCS} ${PUBLIC_HDRS} ${PRIAVTE_HDRS})

if(NOT SKIP_INSTALL_LIBRARIES AND NOT SKIP_INSTALL_ALL )
    install(TARGETS http_parser
        ARCHIVE DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" )
endif()

if(NOT SKIP_INSTALL_HEADERS AND NOT SKIP_INSTALL_ALL )
    install(FILES ${PUBLIC_HDRS} DESTINATION "${CMAKE_INSTALL_PREFIX}/include")
endif()