cmake_minimum_required(VERSION 3.30)
project(dartsim-test CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED TRUE)

block(SCOPE_FOR VARIABLES)
    find_package(DART CONFIG REQUIRED)

    add_library(assert_target_dart ALIAS dart)

    add_executable(main main.cpp)
    target_link_libraries(main PRIVATE dart)
endblock()

block(SCOPE_FOR VARIABLES)
    find_package(PkgConfig REQUIRED)
    pkg_check_modules(dartsim_pc dart REQUIRED IMPORTED_TARGET)

    add_executable(main-pkconfig main.cpp)
    target_link_libraries(main-pkconfig PRIVATE PkgConfig::dartsim_pc)
endblock()
