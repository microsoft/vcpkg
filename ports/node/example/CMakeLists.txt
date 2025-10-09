cmake_minimum_required(VERSION 3.25)
project(process-cc_with_libnode LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 23)
enable_testing()

find_package(node CONFIG REQUIRED)

set(TARGET_NAME process)

#add_executable(${TARGET_NAME} process.cc)
add_executable(${TARGET_NAME} process-fixed.cc)
target_link_libraries(${TARGET_NAME} PRIVATE node)

add_test(NAME ${TARGET_NAME} COMMAND ${TARGET_NAME} ${CMAKE_CURRENT_SOURCE_DIR}/count-hosts.js)
