cmake_minimum_required(VERSION 3.18)

project(Find_LAPACK_external)

# We want to use `FindLAPACK.cmake` despite this setting,
set(CMAKE_FIND_PACKAGE_PREFER_CONFIG TRUE)

find_package(LAPACK REQUIRED)

# FindLAPACK.cmake results
if(NOT TARGET LAPACK::LAPACK)
    message(SEND_ERROR "LAPACK::LAPACK missing after find_package(LAPACK REQUIRED).")
endif()
if(NOT DEFINED LAPACK_LIBRARIES)
    message(SEND_ERROR "LAPACK_LIBRARIES unset after find_package(LAPACK REQUIRED).")
endif()

find_package(PkgConfig REQUIRED)
pkg_check_modules(LAPACK_PC REQUIRED IMPORTED_TARGET lapack)
