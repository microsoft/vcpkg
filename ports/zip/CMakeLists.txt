cmake_minimum_required(VERSION 3.19)
project(zip VERSION "2025.06.13" LANGUAGES C)

set(HOMEPAGE_URL "https://github.com/kuba--/${PROJECT_NAME}")
set(DESCRIPTION "A portable, simple zip library written in C")

set(CMAKE_C_STANDARD 90)

set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}")
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}")

add_subdirectory(src)

install(FILES "${CMAKE_CURRENT_SOURCE_DIR}/src/${PROJECT_NAME}Config.cmake"
        DESTINATION share/${PROJECT_NAME})
