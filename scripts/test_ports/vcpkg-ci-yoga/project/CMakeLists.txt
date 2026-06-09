cmake_minimum_required(VERSION 3.16)
project(vcpkg-ci-yoga)

find_package(yoga CONFIG REQUIRED)

add_executable(main main.cpp)
target_link_libraries(main PRIVATE yoga::yogacore)
