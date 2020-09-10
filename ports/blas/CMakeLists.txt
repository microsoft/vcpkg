cmake_minimum_required(VERSION 3.17)

project(Find_BLAS_external)
find_package(BLAS REQUIRED)
#TODO make sure that the found BLAS is outside VCPKG
