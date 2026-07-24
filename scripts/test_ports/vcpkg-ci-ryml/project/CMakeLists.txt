cmake_minimum_required(VERSION 3.16)
project(vcpkg-ci-ryml)

find_package(ryml CONFIG REQUIRED)

add_executable(main main.cpp)
target_link_libraries(main PRIVATE ryml::ryml)
