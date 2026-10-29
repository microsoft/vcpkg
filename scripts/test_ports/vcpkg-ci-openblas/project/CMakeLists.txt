cmake_minimum_required(VERSION 3.10)

project(vcpkg-ci-openblas C)

find_package(OpenBLAS CONFIG REQUIRED)

add_executable(fortran-interface main.c)
target_link_libraries(fortran-interface PRIVATE OpenBLAS::OpenBLAS)
