cmake_minimum_required(VERSION 3.30)

project(vcpkg-ci-mpg123 C)

find_package(mpg123 REQUIRED)

add_executable(main main.c)
target_link_libraries(main PRIVATE MPG123::libmpg123)

find_package(PkgConfig REQUIRED)
pkg_check_modules(MPG123_PC REQUIRED IMPORTED_TARGET libmpg123)

add_executable(main-pc main.c)
target_link_libraries(main-pc PRIVATE PkgConfig::MPG123_PC)
