cmake_minimum_required(VERSION 3.7)
project(rpath-macho-test CXX)

set(TEST_STRING "" CACHE STRING "")

set(CMAKE_SKIP_INSTALL_RPATH TRUE)

add_library(rpath-macho-backend-lib++ transitive.cpp)
target_compile_definitions(rpath-macho-backend-lib++ PRIVATE "TEST_STRING=\"${TEST_STRING}\"")

add_library(rpath-macho-test-lib lib.cpp)
target_link_libraries(rpath-macho-test-lib PRIVATE rpath-macho-backend-lib++)

add_executable(rpath-macho-test-tool main.cpp)
target_link_libraries(rpath-macho-test-tool PRIVATE rpath-macho-test-lib)

install(TARGETS rpath-macho-backend-lib++ rpath-macho-test-lib rpath-macho-test-tool)
