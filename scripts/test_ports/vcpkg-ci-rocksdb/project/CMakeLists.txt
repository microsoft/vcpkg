cmake_minimum_required(VERSION 3.16)
project(vcpkg-ci-rocksdb C CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

find_package(RocksDB CONFIG REQUIRED)

# Windows DLL builds export only the C API and do not provide RocksDB::rocksdb.
if(TARGET RocksDB::rocksdb)
    add_executable(main main.cpp)
    target_link_libraries(main PRIVATE RocksDB::rocksdb)
endif()

if(TARGET RocksDB::rocksdb-shared)
    add_executable(main-c main.c)
    target_link_libraries(main-c PRIVATE RocksDB::rocksdb-shared)
endif()
