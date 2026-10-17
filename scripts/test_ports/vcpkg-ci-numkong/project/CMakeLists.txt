cmake_minimum_required(VERSION 3.16)
project(vcpkg-ci-numkong)

find_package(unofficial-numkong CONFIG REQUIRED)
add_executable(main main.cpp)
target_link_libraries(main PRIVATE unofficial::numkong::nk_shared)
