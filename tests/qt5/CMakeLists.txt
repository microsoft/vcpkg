
cmake_minimum_required(VERSION 3.6)
project(qt5-base-test)
set(CMAKE_AUTOMOC ON)
find_package(Qt5Widgets)
find_package(ZLIB)
find_library(PCRE_LIBRARY NAMES pcre16)
add_executable(test_qt main.cpp)

target_link_libraries(test_qt Qt5::Widgets ZLIB::ZLIB ${PCRE_LIBRARY})