cmake_minimum_required(VERSION 3.10)
project(soci-test CXX)

set(CMAKE_CXX_STANDARD 14)

# Sqlite3 is not optional, we only test the OPTIONAL_COMPONENTS keyword.
find_package(SOCI CONFIG REQUIRED COMPONENTS MySQL PostgreSQL OPTIONAL_COMPONENTS SQLite3)

add_executable(individual main.cpp)
target_link_libraries(individual PRIVATE SOCI::MySQL)
target_link_libraries(individual PRIVATE SOCI::PostgreSQL)
target_link_libraries(individual PRIVATE SOCI::SQLite3)

add_executable(uniform main.cpp)
target_link_libraries(uniform PRIVATE SOCI::soci)
