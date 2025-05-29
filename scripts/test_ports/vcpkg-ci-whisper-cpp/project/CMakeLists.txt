cmake_minimum_required(VERSION 3.16)
project(whisper-cpp-test)

find_package(whisper CONFIG REQUIRED)

add_executable(main main.cxx)
add_library(imported::whisper ALIAS whisper)
target_link_libraries(main PRIVATE imported::whisper)

find_package(PkgConfig REQUIRED)
pkg_check_modules(whisper-cpp whisper REQUIRED IMPORTED_TARGET)

add_executable(main-pkconfig main.cxx)
target_link_libraries(main-pkconfig PRIVATE PkgConfig::whisper-cpp)
