cmake_minimum_required(VERSION 3.10...3.30)
project(mysql-connector-cpp-test CXX)

if(APPLE)
    set(CMAKE_CXX_STANDARD 11)
endif()

# proper export
add_executable(unofficial-mysql-connector-cpp main.cpp)
find_package(unofficial-mysql-connector-cpp CONFIG REQUIRED)
target_link_libraries(unofficial-mysql-connector-cpp PRIVATE unofficial::mysql-connector-cpp::connector)

# partial re-implementation
add_executable(mysql-concpp-xdevapi main.cpp)
find_package(mysql-concpp CONFIG REQUIRED)
target_link_libraries(mysql-concpp-xdevapi PRIVATE $<IF:$<TARGET_EXISTS:mysql::concpp-xdevapi>,mysql::concpp-xdevapi,mysql::concpp-xdevapi-static>)

if("jdbc" IN_LIST FEATURES)
    # proper export
    add_executable(unofficial-mysql-connector-cpp-jdbc jdbc.cpp)
    target_link_libraries(unofficial-mysql-connector-cpp-jdbc PRIVATE unofficial::mysql-connector-cpp::connector-jdbc)

    # partial re-implementation
    add_executable(mysql-concpp-jdbc jdbc.cpp)
    target_link_libraries(mysql-concpp-jdbc PRIVATE $<IF:$<TARGET_EXISTS:mysql::concpp-jdbc>,mysql::concpp-jdbc,mysql::concpp-jdbc-static>)
endif()
