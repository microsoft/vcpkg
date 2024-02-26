cmake_minimum_required(VERSION 3.10)
project(test)
set(CMAKE_CXX_STANDARD 11)
add_executable(main main.cpp)
find_package(SOCI CONFIG REQUIRED)
# Using core (loading backends at runtime)
target_link_libraries(main PRIVATE $<IF:$<TARGET_EXISTS:SOCI::soci_core>,SOCI::soci_core,SOCI::soci_core_static>)
# Using the mysql backend directly
target_link_libraries(main PRIVATE $<IF:$<TARGET_EXISTS:SOCI::soci_mysql>,SOCI::soci_mysql,SOCI::soci_mysql_static>)
# Using the postgresql backend directly
target_link_libraries(main PRIVATE $<IF:$<TARGET_EXISTS:SOCI::soci_postgresql>,SOCI::soci_postgresql,SOCI::soci_postgresql_static>)
# Using the sqlite3 backend directly
target_link_libraries(main PRIVATE $<IF:$<TARGET_EXISTS:SOCI::soci_sqlite3>,SOCI::soci_sqlite3,SOCI::soci_sqlite3_static>)
