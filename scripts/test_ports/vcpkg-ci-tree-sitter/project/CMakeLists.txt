cmake_minimum_required(VERSION 3.30)
project(tree-sitter-test C)

find_package(PkgConfig REQUIRED)
pkg_check_modules(tree-sitter_pc tree-sitter REQUIRED IMPORTED_TARGET)
pkg_check_modules(tree-sitter-c_pc tree-sitter-c REQUIRED IMPORTED_TARGET)

add_executable(main-pkconfig main.c)
target_link_libraries(main-pkconfig PRIVATE
    PkgConfig::tree-sitter_pc
    PkgConfig::tree-sitter-c_pc
)
