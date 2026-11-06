cmake_minimum_required(VERSION 3.25)
project(libscran-umappp-test CXX)

find_package(libscran_umappp CONFIG REQUIRED)

add_executable(main main.cpp)
target_link_libraries(main PRIVATE libscran::umappp)
