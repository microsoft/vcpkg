cmake_minimum_required(VERSION 3.20)
project(glad)

add_subdirectory(cmake)
glad_add_library(glad STATIC REPRODUCIBLE API gl:core=4.6)
target_link_libraries(${PROJECT_NAME} glad)
target_include_directories(${PROJECT_NAME} PRIVATE "gladsources/glad/include")