cmake_minimum_required(VERSION 3.7)
project(soci-test CXX)

if(APPLE)
    set(CMAKE_CXX_STANDARD 11)
endif()

add_executable(main main.cpp)

find_package(SOCI 4.1 COMPONENTS MySQL PostgreSQL SQLite3 CONFIG REQUIRED)
target_link_libraries(main PRIVATE SOCI::SOCI)
