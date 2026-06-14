cmake_minimum_required(VERSION 3.16)
project(vcpkg-ci-numactl)

find_package(unofficial-numa CONFIG REQUIRED)
add_executable(vcpkg-ci-numactl main.cpp)
target_link_libraries(vcpkg-ci-numactl PRIVATE unofficial::numa::numa)

find_package(PkgConfig REQUIRED)
pkg_check_modules(numa IMPORTED_TARGET REQUIRED numa)
add_executable(vcpkg-ci-numactl-pc main.cpp)
target_link_libraries(vcpkg-ci-numactl-pc PRIVATE PkgConfig::numa)
