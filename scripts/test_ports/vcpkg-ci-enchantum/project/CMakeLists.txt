cmake_minimum_required(VERSION 3.20)
project(vcpkg_ci_enchantum LANGUAGES CXX)

find_package(enchantum CONFIG REQUIRED)

add_executable(vcpkg_ci_enchantum main.cpp)
target_link_libraries(vcpkg_ci_enchantum PRIVATE enchantum::enchantum)
