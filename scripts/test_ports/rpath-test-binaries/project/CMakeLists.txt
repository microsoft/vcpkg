cmake_minimum_required(VERSION 3.7)
project(rpath-test CXX)

set(TEST_STRING "" CACHE STRING "")

add_library(rpath-test-lib lib.cpp)
target_compile_definitions(rpath-test-lib PRIVATE "TEST_STRING=\"${TEST_STRING}\"")

add_executable(rpath-test-tool main.cpp)
target_link_libraries(rpath-test-tool PRIVATE rpath-test-lib)

install(TARGETS rpath-test-lib rpath-test-tool)
