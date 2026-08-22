cmake_minimum_required(VERSION 3.17)

project(Find_CBLAS_external)

find_package(PkgConfig REQUIRED)
pkg_check_modules(CBLAS_PC REQUIRED IMPORTED_TARGET cblas)
