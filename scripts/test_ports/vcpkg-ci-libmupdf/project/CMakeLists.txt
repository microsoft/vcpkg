cmake_minimum_required(VERSION 3.10)
project(libmupdf-test C CXX)

find_package(unofficial-libmupdf REQUIRED)

add_executable(mu-office-test "${SOURCE_PATH}/source/tests/mu-office-test.c")
target_link_libraries(mu-office-test PRIVATE unofficial::libmupdf::libmupdf)

if(NOT WIN32)
    target_include_directories(mu-office-test AFTER PRIVATE "${CMAKE_CURRENT_LIST_DIR}")
endif()
