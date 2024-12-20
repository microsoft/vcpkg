cmake_minimum_required(VERSION 3.26)

project(vcpkg-ci-orange-math)

set(CMAKE_CXX_STANDARD 26)

add_executable(main main.cpp)

find_package(orange-math CONFIG REQUIRED)
target_link_libraries(main PRIVATE omath::omath)
