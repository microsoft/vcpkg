cmake_minimum_required(VERSION 3.18)  

project(vcpkg-ci-libaec C)

find_package(libaec CONFIG REQUIRED)
  
add_executable(compression main.c)
if(BUILD_SHARED_LIBS)
    target_link_libraries(compression PRIVATE sz_shared aec_shared)
else()
    target_link_libraries(compression PRIVATE sz_static aec_static)
endif()