cmake_minimum_required(VERSION 3.10)
project(test)
set(CMAKE_CXX_STANDARD 11)
add_executable(main main.cpp)
# Each component imports a target:
# TARGETS: PCRE2::8BIT PCRE2::16BIT PCRE2::32BIT PCRE2::POSIX
find_package(pcre2 CONFIG REQUIRED)
target_link_libraries(main PRIVATE PCRE2::8BIT PCRE2::16BIT PCRE2::32BIT PCRE2::POSIX)
