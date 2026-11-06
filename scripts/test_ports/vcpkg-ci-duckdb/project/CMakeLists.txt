cmake_minimum_required(VERSION 3.16)
project(duckdb-test C CXX)

add_executable(main main.c)

find_package(DuckDB CONFIG REQUIRED)
if(BUILD_SHARED_LIBS)
    add_library(imported::duckdb ALIAS duckdb)
else()
    add_library(imported::duckdb ALIAS duckdb_static)
endif()
target_link_libraries(main PRIVATE imported::duckdb)
install(TARGETS main RUNTIME DESTINATION bin/vcpkg-ci-duckdb)
