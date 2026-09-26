cmake_minimum_required(VERSION 3.30)
project(pagmo2-test CXX)

find_package(pagmo CONFIG REQUIRED)

add_executable(main main.cpp)
target_link_libraries(main PRIVATE Pagmo::pagmo)
install(TARGETS main RUNTIME DESTINATION "bin/vcpkg-ci-pagmo2")
