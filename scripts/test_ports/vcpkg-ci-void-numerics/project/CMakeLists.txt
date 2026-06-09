cmake_minimum_required(VERSION 3.16)
project(vcpkg-ci-void-numerics)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(void-numerics CONFIG REQUIRED)

add_executable(main main.cpp)
target_link_libraries(main PRIVATE void-numerics::void-numerics)
