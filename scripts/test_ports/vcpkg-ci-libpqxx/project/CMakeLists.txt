cmake_minimum_required(VERSION 3.30)
project(libpqxx-test CXX)

set(CMAKE_CXX_STANDARD 17)

find_package(libpqxx CONFIG REQUIRED)

add_executable(main main.cpp)
target_link_libraries(main PRIVATE libpqxx::pqxx)

if(NOT (WIN32 AND NOT MINGW))
    find_package(PkgConfig REQUIRED)
    pkg_check_modules(libpqxx IMPORTED_TARGET REQUIRED libpqxx)

    add_executable(main-pkgconfig main.cpp)
    target_link_libraries(main-pkgconfig PRIVATE PkgConfig::libpqxx)
endif()
