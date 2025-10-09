cmake_minimum_required(VERSION 3.25.1)
project(tdlib-test CXX)
set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Td CONFIG REQUIRED)
add_executable(main main.cpp)
target_link_libraries(main PRIVATE Td::TdStatic)

find_package(PkgConfig REQUIRED)
pkg_check_modules(tdclient REQUIRED IMPORTED_TARGET tdclient)
add_executable(main2 main.cpp)
target_link_libraries(main2 PRIVATE PkgConfig::tdclient)
