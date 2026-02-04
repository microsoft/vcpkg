cmake_minimum_required(VERSION 3.30)
project(box2d-test C)

find_package(box2d CONFIG REQUIRED)

add_executable(main main.c)
target_link_libraries(main PRIVATE box2d::box2d)
