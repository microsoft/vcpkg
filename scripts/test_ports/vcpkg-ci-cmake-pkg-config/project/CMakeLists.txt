cmake_minimum_required(VERSION 3.31)
project(vcpkg-ci-cmake-pkg-config CXX)

# IMPORT was introduced in cmake 4.1
if(CMAKE_VERSION VERSION_GREATER_EQUAL "4.1")
    message("Try keyword IMPORT")
    cmake_pkg_config(IMPORT zlib REQUIRED)
else()
    message("Try keyword EXTRACT")
    cmake_pkg_config(EXTRACT zlib REQUIRED)
endif()

add_executable(main main.cpp)

if(CMAKE_VERSION VERSION_GREATER_EQUAL "4.1")
    target_link_libraries(main PRIVATE PkgConfig::zlib)
else()
    target_include_directories(main PRIVATE ${CMAKE_PKG_CONFIG_INCLUDES})
    target_link_libraries(main PRIVATE ${CMAKE_PKG_CONFIG_LIBNAMES})
    target_link_directories(main PRIVATE ${CMAKE_PKG_CONFIG_LIBDIRS})
endif()