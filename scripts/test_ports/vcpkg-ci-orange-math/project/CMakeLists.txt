cmake_minimum_required(VERSION 3.26)

project(vcpkg-ci-orange-math)

set(CMAKE_CXX_STANDARD 23)

add_executable(main main.cpp)

find_package(omath CONFIG REQUIRED)
target_link_libraries(main PRIVATE omath::omath)
