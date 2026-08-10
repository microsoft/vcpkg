cmake_minimum_required(VERSION 3.16)
project(vcpkg-ci-sfparse C)

find_package(unofficial-sfparse CONFIG REQUIRED)

add_executable(main main.c)
target_link_libraries(main PRIVATE unofficial::sfparse::sfparse)
