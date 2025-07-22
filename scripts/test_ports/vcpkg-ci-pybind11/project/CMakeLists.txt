cmake_minimum_required(VERSION 3.30)
project(pybind11-test CXX)

find_package(Python COMPONENTS Interpreter Development)
find_package(pybind11 CONFIG)

# pybind11 method:
pybind11_add_module(test-pybind11 main.cpp)

# Python method:
Python_add_library(test-python main.cpp)
target_link_libraries(test-python PRIVATE pybind11::headers)
