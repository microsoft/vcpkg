cmake_minimum_required(VERSION 3.26)

project(vcpkg-ci-vmprotect-sdk)

set(CMAKE_CXX_STANDARD 20)

add_executable(main main.cpp)

find_package(vmprotect_sdk CONFIG REQUIRED)
target_link_libraries(main PRIVATE vmprotect_sdk::vmprotect_sdk)
