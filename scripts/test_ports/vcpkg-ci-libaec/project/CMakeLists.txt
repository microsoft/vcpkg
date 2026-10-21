cmake_minimum_required(VERSION 3.30)
project(libaec-test C)

find_package(libaec CONFIG REQUIRED)

add_executable(main main.c)
target_link_libraries(main PRIVATE libaec::aec)
