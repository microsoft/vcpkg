cmake_minimum_required(VERSION 3.16)
project(vcpkg-ci-node-addon-api)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

add_definitions(-DNAPI_VERSION=3)

find_package(unofficial-node-addon-api CONFIG REQUIRED)

add_library(hello SHARED hello.cpp)
set_target_properties(hello PROPERTIES PREFIX "" SUFFIX ".node")
target_link_libraries(hello PRIVATE unofficial::node-addon-api::node-addon-api)
