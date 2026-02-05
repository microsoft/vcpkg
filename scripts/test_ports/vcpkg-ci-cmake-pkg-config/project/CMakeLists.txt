cmake_minimum_required(VERSION 4.2.3)
project(vcpkg-ci-cmake-pkg-config CXX)

cmake_pkg_config(IMPORT zlib REQUIRED)

add_executable(main main.cpp)
target_link_libraries(main PRIVATE PkgConfig::zlib)