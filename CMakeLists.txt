# CMakeLists.txt
cmake_minimum_required(VERSION 3.0)
project(rttr)

find_package(rttr REQUIRED)

link_libraries(rttr)
add_executable(main main.cpp)