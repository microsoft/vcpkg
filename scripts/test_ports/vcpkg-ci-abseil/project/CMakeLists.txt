cmake_minimum_required(VERSION 3.10)
project(test)
set(CMAKE_CXX_STANDARD 11)
add_executable(main main.cpp)
find_package(absl CONFIG REQUIRED)
# note: 174 additional targets are not displayed.
target_link_libraries(main PRIVATE absl::any absl::log absl::base absl::bits)
