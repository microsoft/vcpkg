cmake_minimum_required(VERSION 3.24)

project(vcpkg-ci-lief LANGUAGES C CXX)

set(CMAKE_CXX_STANDARD 14)

find_package(LIEF CONFIG REQUIRED)
add_executable(main main.cpp)
target_link_libraries(main PRIVATE LIEF::LIEF)

find_package(PkgConfig REQUIRED)
pkg_check_modules(LIEF REQUIRED IMPORTED_TARGET LIEF)
add_executable(main2 main.cpp)
target_link_libraries(main2 PRIVATE PkgConfig::LIEF)
