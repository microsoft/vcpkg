cmake_minimum_required(VERSION 3.10)
project(decimal128test)

find_package(unofficial-intelrdfpmathlib CONFIG REQUIRED)
add_executable(main main.cpp)
target_link_libraries(main PRIVATE unofficial::intel::intel_decimal128)
