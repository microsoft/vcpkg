cmake_minimum_required(VERSION 3.10)
project(test)
set(CMAKE_CXX_STANDARD 11)
add_executable(main main.cpp)
# C API
find_package(libLAS CONFIG REQUIRED)
target_link_libraries(main PRIVATE $<$<PLATFORM_ID:Windows>:lib>las_c)
target_include_directories(main SYSTEM PRIVATE ${libLAS_INCLUDE_DIRS})
# C++ API
find_package(libLAS CONFIG REQUIRED)
target_link_libraries(main PRIVATE $<$<PLATFORM_ID:Windows>:lib>las)
target_include_directories(main SYSTEM PRIVATE ${libLAS_INCLUDE_DIRS})
