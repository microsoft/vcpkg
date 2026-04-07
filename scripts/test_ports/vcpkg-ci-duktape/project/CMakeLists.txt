cmake_minimum_required(VERSION 3.15)
project(vcpkg_ci_duktape)

set(CMAKE_CXX_STANDARD 17)

find_package(unofficial-duktape CONFIG REQUIRED)

add_executable(vcpkg_ci_duktape main.cpp)
target_link_libraries(vcpkg_ci_duktape PRIVATE unofficial::duktape::duktape)
