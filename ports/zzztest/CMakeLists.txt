cmake_minimum_required(VERSION 3.0)

project(zzztest CXX)

set(SRC test.cpp)

add_executable(zzztest ${SRC})

install (TARGETS zzztest RUNTIME DESTINATION bin)