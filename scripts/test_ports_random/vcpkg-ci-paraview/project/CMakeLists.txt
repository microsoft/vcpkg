cmake_minimum_required(VERSION 3.10)
project(test)
set(CMAKE_CXX_STANDARD 11)
add_executable(main main.cpp)
find_package(paraview CONFIG REQUIRED)
# note: 338 additional targets are not displayed.
target_link_libraries(main PRIVATE Boxlib::C Mili::Mili SILO::SILO Boxlib::Boxlib)
