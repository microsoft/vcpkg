cmake_minimum_required(VERSION 3.10)
project(test)
set(CMAKE_CXX_STANDARD 11)
add_executable(main main.cpp)
find_package(activemq-cpp CONFIG REQUIRED)
# note: 1 additional targets are not displayed.
target_link_libraries(main PRIVATE unofficial::activemq-cpp::apr unofficial::activemq-cpp::ws2 unofficial::activemq-cpp::rpcrt4 unofficial::activemq-cpp::mswsock)
