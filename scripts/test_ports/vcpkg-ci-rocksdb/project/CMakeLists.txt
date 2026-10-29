cmake_minimum_required(VERSION 3.16)
project(vcpkg-ci-rocksdb)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

find_package(RocksDB CONFIG REQUIRED)

add_executable(main main.cpp)
target_link_libraries(main PRIVATE RocksDB::rocksdb)
