cmake_minimum_required(VERSION 3.16)
project(sail-test C CXX)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# C libraries
find_package(Sail CONFIG REQUIRED)
find_package(SailManip CONFIG REQUIRED)

add_executable(main-c main.c)
target_link_libraries(main-c PRIVATE SAIL::sail SAIL::sail-manip)

# C++ bindings
find_package(SailC++ CONFIG REQUIRED)

add_executable(main-cpp main.cpp)
target_link_libraries(main-cpp PRIVATE SAIL::sail-c++)

install(TARGETS main-c main-cpp RUNTIME DESTINATION "bin/vcpkg-ci-sail")
