cmake_minimum_required(VERSION 3.30)
project(kubernetes-test C)

find_package(kubernetes CONFIG REQUIRED)

set(SOURCE_FILE "REQUIRED" CACHE STRING "")
add_executable(main "${SOURCE_FILE}")
target_link_libraries(main PRIVATE kubernetes::kubernetes)
