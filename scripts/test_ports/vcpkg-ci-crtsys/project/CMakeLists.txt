cmake_minimum_required(VERSION 3.30)
project(crtsys-vcpkg-consumer LANGUAGES C CXX)

set(CRTSYS_NTL_MAIN ON)
find_package(crtsys CONFIG REQUIRED)

crtsys_add_driver(crtsys_vcpkg_consumer main.cpp)
