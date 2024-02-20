cmake_minimum_required(VERSION 3.10)
project(test)
set(CMAKE_CXX_STANDARD 11)
add_executable(main main.cpp)
find_package(arg_router REQUIRED)
target_link_libraries(my_exe PUBLIC arg_router::arg_router)

