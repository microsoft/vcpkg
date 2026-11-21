cmake_minimum_required(VERSION 3.16)
project(vcpkg-ci-freerdp LANGUAGES C)

find_package(FreeRDP CONFIG REQUIRED)

add_executable(${PROJECT_NAME} main.c)
target_link_libraries(${PROJECT_NAME} PRIVATE freerdp)
