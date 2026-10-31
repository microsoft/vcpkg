cmake_minimum_required(VERSION 3.20)
project(vcpkg_ci_glaze LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(glaze CONFIG REQUIRED)
glaze_setup_asio()

add_executable(vcpkg_ci_glaze main.cpp)
target_link_libraries(vcpkg_ci_glaze PRIVATE glaze::glaze glaze::asio)
