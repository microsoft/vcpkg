cmake_minimum_required(VERSION 3.16)
project(whisper-cpp-test)

find_package(whisper CONFIG REQUIRED)

add_executable(test-cmake main.cxx)
add_library(imported::whisper ALIAS whisper)
target_link_libraries(test-cmake PRIVATE imported::whisper)

find_package(PkgConfig REQUIRED)
pkg_check_modules(whisper-cpp whisper REQUIRED IMPORTED_TARGET)

add_executable(test-pkconfig main.cxx)
target_link_libraries(test-pkconfig PRIVATE PkgConfig::whisper-cpp)
