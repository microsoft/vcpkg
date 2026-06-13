cmake_minimum_required(VERSION 3.16)
project(starlink-ast-test CXX)

find_path(AST_INCLUDE_DIR ast.h REQUIRED)
find_library(AST_LIBRARY ast REQUIRED)

add_executable(main main.cpp)
target_include_directories(main PRIVATE ${AST_INCLUDE_DIR})
target_link_libraries(main PRIVATE ${AST_LIBRARY})
