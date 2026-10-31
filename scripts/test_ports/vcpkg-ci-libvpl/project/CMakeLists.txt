cmake_minimum_required(VERSION 3.15)
project(vcpkg-ci-libvpl)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

################################################################################
#                              Use cmake config                                #
################################################################################
find_package(VPL CONFIG REQUIRED)
add_executable(vcpkg-ci-libvpl main.cpp)
target_link_libraries(vcpkg-ci-libvpl PRIVATE VPL::dispatcher)


################################################################################
#                                Use pkg-config                                #
################################################################################
find_package(PkgConfig)
pkg_check_modules(vpl REQUIRED IMPORTED_TARGET vpl)
add_executable(vcpkg-ci-libvpl-pc main.cpp)
target_link_libraries(vcpkg-ci-libvpl-pc PRIVATE PkgConfig::vpl)
