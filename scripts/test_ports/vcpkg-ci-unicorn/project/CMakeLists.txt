cmake_minimum_required(VERSION 3.5)

project(vcpkg-ci-unicorn C)

set(CMAKE_C_STANDARD 11)

find_package(PkgConfig REQUIRED)
pkg_check_modules(unicorn REQUIRED IMPORTED_TARGET unicorn)

add_executable(main main.c)

target_link_libraries(main PRIVATE PkgConfig::unicorn)
