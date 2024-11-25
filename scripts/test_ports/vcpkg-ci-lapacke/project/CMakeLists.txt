cmake_minimum_required(VERSION 3.10..3.30)
project(lapacke-test C Fortran)

find_package(lapacke CONFIG REQUIRED)

add_executable(main main.c)
target_link_libraries(main PRIVATE lapacke)

find_package(PkgConfig REQUIRED)
pkg_check_modules(pc_lapacke lapacke REQUIRED IMPORTED_TARGET)

# Fixme: Carry Fortran linker language eqivalent through pc files
#add_executable(main-pkgconfig main.c)
#target_link_libraries(main-pkgconfig PRIVATE PkgConfig::pc_lapacke)
