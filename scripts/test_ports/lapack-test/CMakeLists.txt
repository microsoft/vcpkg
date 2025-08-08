cmake_minimum_required(VERSION 3.17)

project(Find_LAPACK_external)
find_package(LAPACK REQUIRED)
find_package(PkgConfig REQUIRED)
pkg_check_modules(LAPACK_PC REQUIRED IMPORTED_TARGET lapack)
