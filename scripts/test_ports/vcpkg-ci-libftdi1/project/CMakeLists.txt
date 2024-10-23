cmake_minimum_required(VERSION 3.29)
project(libftdi1-test CXX)

set(CMAKE_CXX_STANDARD 11)

add_executable(main main.cpp)

find_package(PkgConfig REQUIRED)
pkg_check_modules(libftdipp1 IMPORTED_TARGET REQUIRED libftdipp1)
target_link_libraries(main PRIVATE PkgConfig::libftdipp1)

# subdir to scope side effects
add_subdirectory(cmake-usage)
