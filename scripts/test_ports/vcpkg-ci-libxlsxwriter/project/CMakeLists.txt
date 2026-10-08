cmake_minimum_required(VERSION 3.16)
project(libxlsxwriter-test C)

add_executable(main main.c)

find_package(PkgConfig REQUIRED)
pkg_check_modules(libxlsxwriter xlsxwriter REQUIRED IMPORTED_TARGET)
target_link_libraries(main PRIVATE PkgConfig::libxlsxwriter)
