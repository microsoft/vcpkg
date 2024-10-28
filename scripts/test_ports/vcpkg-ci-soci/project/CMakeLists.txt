cmake_minimum_required(VERSION 3.7)
project(soci-test CXX)

if(APPLE)
    set(CMAKE_CXX_STANDARD 11)
endif()

add_executable(main main.cpp)

find_package(SOCI CONFIG REQUIRED)
target_link_libraries(main PRIVATE $<IF:$<TARGET_EXISTS:SOCI::soci_mysql>,SOCI::soci_mysql,SOCI::soci_mysql_static>)
target_link_libraries(main PRIVATE $<IF:$<TARGET_EXISTS:SOCI::soci_postgresql>,SOCI::soci_postgresql,SOCI::soci_postgresql_static>)
target_link_libraries(main PRIVATE $<IF:$<TARGET_EXISTS:SOCI::soci_sqlite3>,SOCI::soci_sqlite3,SOCI::soci_sqlite3_static>)
