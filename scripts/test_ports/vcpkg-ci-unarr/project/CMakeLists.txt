cmake_minimum_required(VERSION 3.25.1)
project(unarr-test LANGUAGES C)
set(CMAKE_C_STANDARD 99)
set(CMAKE_C_STANDARD_REQUIRED ON)

find_package(unarr CONFIG REQUIRED)
add_executable(main main.c)
target_link_libraries(main PRIVATE unarr::unarr)

find_package(PkgConfig REQUIRED)
pkg_check_modules(libunarr REQUIRED IMPORTED_TARGET libunarr)
add_executable(main2 main.c)
target_link_libraries(main2 PRIVATE PkgConfig::libunarr)
