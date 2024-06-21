cmake_minimum_required(VERSION 3.17)

project(Find_BLAS_external)
find_package(BLAS REQUIRED)
find_package(PkgConfig REQUIRED)
pkg_check_modules(BLAS_PC REQUIRED IMPORTED_TARGET blas)
