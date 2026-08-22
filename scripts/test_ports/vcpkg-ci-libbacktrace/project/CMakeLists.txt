cmake_minimum_required(VERSION 3.15)
project(libbacktrace-test LANGUAGES C)

find_package(unofficial-libbacktrace CONFIG REQUIRED)

add_executable(main main.c)
target_link_libraries(main PRIVATE unofficial::libbacktrace::libbacktrace)
