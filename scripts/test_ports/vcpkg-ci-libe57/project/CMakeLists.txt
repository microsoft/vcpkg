cmake_minimum_required(VERSION 3.16)
project(libe57-test CXX)

set(CMAKE_CXX_STANDARD 14)

add_executable(main main.cpp)

find_package(E57RefImpl CONFIG REQUIRED)
target_link_libraries(main PRIVATE ${E57RefImpl_LIBRARIES})
target_include_directories(main PRIVATE ${E57RefImpl_INCLUDE_DIRS})
