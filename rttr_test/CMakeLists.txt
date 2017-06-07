# CMakeLists.txt
cmake_minimum_required(VERSION 3.0)
project(test)

#find_path(RTTR_INCLUDE_DIR rttr/registration)
#include_directories(${RTTR_INCLUDE_DIR})

find_package(rttr REQUIRED)
add_executable(main main.cpp)

TARGET_LINK_LIBRARIES(main PRIVATE RTTR::Core)