cmake_minimum_required(VERSION 3.16)
project(libharu-test CXX)

add_executable(main main.cpp)

find_package(unofficial-libharu CONFIG REQUIRED)
target_link_libraries(main PRIVATE unofficial::libharu::hpdf)
