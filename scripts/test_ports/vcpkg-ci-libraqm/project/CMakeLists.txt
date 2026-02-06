cmake_minimum_required(VERSION 3.30)
project(libraqm-test C)

find_package(unofficial-libraqm CONFIG REQUIRED)

add_executable(main main.c)
target_link_libraries(main PRIVATE unofficial::libraqm::libraqm)

find_package(PkgConfig REQUIRED)
pkg_check_modules(libraqm_pc raqm REQUIRED IMPORTED_TARGET)

add_executable(main-pkconfig main.c)
target_link_libraries(main-pkconfig PRIVATE PkgConfig::libraqm_pc)
