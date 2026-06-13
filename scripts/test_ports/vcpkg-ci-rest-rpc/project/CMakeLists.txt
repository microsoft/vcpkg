cmake_minimum_required(VERSION 3.12)
project(soci-test CXX)

add_executable(main main.cpp)

find_package(unofficial-rest-rpc CONFIG REQUIRED)
target_link_libraries(main unofficial::rest-rpc::rest-rpc)
