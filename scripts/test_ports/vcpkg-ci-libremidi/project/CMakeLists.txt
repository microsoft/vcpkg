cmake_minimum_required(VERSION 3.30)
project(libremidi-test CXX)

find_package(libremidi CONFIG REQUIRED)
add_library(imported::libremidi ALIAS libremidi)

add_executable(main main.cpp)
target_link_libraries(main PRIVATE imported::libremidi)
