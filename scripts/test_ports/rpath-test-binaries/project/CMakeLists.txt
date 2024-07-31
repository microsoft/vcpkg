cmake_minimum_required(VERSION 3.7)
project(rpath-test CXX)

set(TEST_STRING "" CACHE STRING "")

set(CMAKE_SKIP_INSTALL_RPATH TRUE)

add_library(rpath-backend-lib transitive.cpp)
target_compile_definitions(rpath-backend-lib PRIVATE "TEST_STRING=\"${TEST_STRING}\"")

add_library(rpath-test-lib lib.cpp)
target_link_libraries(rpath-test-lib PRIVATE rpath-backend-lib)

add_executable(rpath-test-tool main.cpp)
target_link_libraries(rpath-test-tool PRIVATE rpath-test-lib)

install(TARGETS rpath-backend-lib rpath-test-lib rpath-test-tool)
