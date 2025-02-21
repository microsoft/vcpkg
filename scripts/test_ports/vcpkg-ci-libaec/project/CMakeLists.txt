cmake_minimum_required(VERSION 3.18)  

project(vcpkg-ci-libaec C)

find_package(libaec CONFIG REQUIRED)
  
add_executable(compression main.c)
target_link_libraries(compression PRIVATE sz aec sz_shared aec_shared)

