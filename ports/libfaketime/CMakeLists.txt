cmake_minimum_required(VERSION 3.12)

project(faketime)

add_library(
        ${PROJECT_NAME}
        src/libfaketime.c
)

if (CMAKE_SYSTEM_NAME STREQUAL "Linux")
    target_link_libraries(
            ${PROJECT_NAME}
            rt
    )
endif()

target_include_directories(${PROJECT_NAME}
        PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}/src
)

file(GLOB_RECURSE PUBLIC_HEADERS "src/*.h")

target_sources(
        ${PROJECT_NAME}
        PUBLIC
        FILE_SET HEADERS
        BASE_DIRS src
        FILES ${PUBLIC_HEADERS}
)

install(TARGETS ${PROJECT_NAME}
        FILE_SET HEADERS
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
        ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
        INCLUDES DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
)
