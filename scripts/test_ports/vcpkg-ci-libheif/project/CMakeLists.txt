cmake_minimum_required(VERSION 3.30)
project(libheif-test C CXX)

find_package(libheif CONFIG REQUIRED)

add_executable(main main.c)
add_library(imported::heif ALIAS heif)
target_link_libraries(main PRIVATE imported::heif)

find_package(PkgConfig REQUIRED)
pkg_check_modules(libheif_pc libheif REQUIRED IMPORTED_TARGET)

add_executable(main-pkconfig main.c)
target_link_libraries(main-pkconfig PRIVATE
    PkgConfig::libheif_pc
)
