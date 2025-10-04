cmake_minimum_required(VERSION 3.16)
project(llama-cpp-test)

find_package(llama CONFIG REQUIRED)

add_executable(test-cmake main.cxx)
add_library(imported::llama ALIAS llama)
target_link_libraries(test-cmake PRIVATE imported::llama)

find_package(PkgConfig REQUIRED)
pkg_check_modules(llama-cpp llama REQUIRED IMPORTED_TARGET)

add_executable(test-pkconfig main.cxx)
target_link_libraries(test-pkconfig PRIVATE PkgConfig::llama-cpp)
