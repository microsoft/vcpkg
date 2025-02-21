# Unconditionally enable Fortran here.
project(pure-fortran Fortran)

add_executable(fmain main.f90)

add_library(flib flib.f90)
