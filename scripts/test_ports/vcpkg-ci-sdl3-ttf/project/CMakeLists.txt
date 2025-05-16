cmake_minimum_required(VERSION 3.30)
project(sdl3-ttf-test C)

find_package(SDL3_ttf CONFIG REQUIRED)

add_executable(main main.c)
target_link_libraries(main PRIVATE SDL3_ttf::SDL3_ttf)

find_package(PkgConfig REQUIRED)
pkg_check_modules(PC_SDL3_TTF sdl3-ttf REQUIRED IMPORTED_TARGET)

add_executable(main-pkconfig main.c)
target_link_libraries(main-pkconfig PRIVATE PkgConfig::PC_SDL3_TTF)
