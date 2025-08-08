cmake_minimum_required(VERSION 3.7)
project(openvpn3-test CXX)

add_executable(main main.cpp)

find_package(unofficial-openvpn3 CONFIG REQUIRED)
target_link_libraries(main PRIVATE unofficial::openvpn3::ovpncli)
