cmake_minimum_required(VERSION 3.16)
project(vcpkg-ci-thorvg)

find_package(PkgConfig REQUIRED)
pkg_check_modules(thorvg IMPORTED_TARGET REQUIRED thorvg-1)

add_executable(main main.cpp)
target_link_libraries(main PRIVATE PkgConfig::thorvg)
