cmake_minimum_required(VERSION 3.7)
project(soci-test CXX)

if(APPLE)
    set(CMAKE_CXX_STANDARD 11)
endif()

add_executable(main main.cpp)

find_package(unofficial-rest-rpc CONFIG REQUIRED)
target_link_libraries(main unofficial::rest-rpc::rest-rpc)
