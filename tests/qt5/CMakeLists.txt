
cmake_minimum_required(VERSION 3.2)
project(qt5-base-test)
set(CMAKE_AUTOMOC ON)
find_package(Qt5Widgets)
add_executable(test_qt main.cpp)

target_link_libraries(test_qt Qt5::Widgets)
