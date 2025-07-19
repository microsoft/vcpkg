cmake_minimum_required(VERSION 3.16)
project(whisper-cpp-test)

find_package(whisper CONFIG REQUIRED)

add_executable(main main.cxx)
add_library(imported::whisper ALIAS whisper)
target_link_libraries(main PRIVATE imported::whisper)
