cmake_minimum_required(VERSION 3.30)
project(vcpkg-ci-bungee LANGUAGES CXX)

find_package(unofficial-bungee CONFIG REQUIRED)

add_executable(cmake-test main.cpp)
target_link_libraries(cmake-test PRIVATE unofficial::bungee::bungee)

if(NOT ANDROID)
    find_package(PkgConfig REQUIRED)
    pkg_check_modules(bungee REQUIRED IMPORTED_TARGET libbungee)

    add_executable(pkgconfig-test main.cpp)
    target_link_libraries(pkgconfig-test PRIVATE PkgConfig::bungee)
endif()
