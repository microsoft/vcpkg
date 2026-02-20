cmake_minimum_required(VERSION 3.31)
project(vcpkg-ci-cmake-pkg-config CXX)

cmake_pkg_config(EXTRACT zlib REQUIRED)
# IMPORT was introduced in cmake 4.1
if(CMAKE_VERSION VERSION_GREATER_EQUAL "4.1")
    cmake_pkg_config(IMPORT zlib REQUIRED)
endif()
add_executable(main main.cpp)
target_link_libraries(main PRIVATE ${CMAKE_PKG_CONFIG_LIBS})