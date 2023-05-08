cmake_minimum_required(VERSION 3.8)
project(sonic
    VERSION 0.2.0
    LANGUAGES C
)

add_library(libsonic sonic.c)
set_target_properties(libsonic
    PROPERTIES
        PUBLIC_HEADER "${CMAKE_SOURCE_DIR}/sonic.h"
        SOVERSION ${PROJECT_VERSION_MAJOR}
        VERSION ${CMAKE_PROJECT_VERSION}
        OUTPUT_NAME sonic
)

add_executable(sonic wave.c main.c)
target_link_libraries(sonic
    PRIVATE
        libsonic
)

install(TARGETS libsonic sonic
    ARCHIVE         DESTINATION lib
    LIBRARY         DESTINATION lib
    PUBLIC_HEADER   DESTINATION include
    RUNTIME         DESTINATION bin
)
