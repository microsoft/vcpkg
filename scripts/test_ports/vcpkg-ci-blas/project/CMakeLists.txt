cmake_minimum_required(VERSION 3.18)  # for BLAS::BLAS

project(vcpkg-ci-blas C)

find_package(BLAS REQUIRED)

add_executable(fortran-interface main.c)
target_link_libraries(fortran-interface PRIVATE BLAS::BLAS)

find_package(PkgConfig REQUIRED)
pkg_check_modules(BLAS_PC REQUIRED IMPORTED_TARGET blas)

add_executable(fortran-interface-pc main.c)
target_link_libraries(fortran-interface-pc PRIVATE PkgConfig::BLAS_PC)
