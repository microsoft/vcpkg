cmake_minimum_required(VERSION 3.30)
project(pybind11-test CXX)

set(PYBIND11_FINDPYTHON ON)
find_package(pybind11 CONFIG REQUIRED)

# Easy
pybind11_add_module(test-pybind11 main.cpp)

# Advanced
Python_add_library(test-python main.cpp)
target_link_libraries(test-python PRIVATE pybind11::headers)
