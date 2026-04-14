cmake_minimum_required(VERSION 3.25.1)

project(tdlib-test LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Td CONFIG REQUIRED)

add_executable(main main.cpp)

if (TARGET Td::tdjson_static)
    target_link_libraries(main PRIVATE Td::tdjson_static)
else()
    target_link_libraries(main PRIVATE Td::TdJson)
endif()

find_package(PkgConfig REQUIRED)

pkg_check_modules(tdjson IMPORTED_TARGET tdjson)
pkg_check_modules(tdjson_static IMPORTED_TARGET tdjson_static)

add_executable(main2 main.cpp)

if (TARGET PkgConfig::tdjson_static)
    target_link_libraries(main2 PRIVATE PkgConfig::tdjson_static)
else()
    target_link_libraries(main2 PRIVATE PkgConfig::tdjson)
endif()
