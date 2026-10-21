cmake_minimum_required(VERSION 3.16)
project(graphite2-test)

find_path(GRAPHITE2_INCLUDE_DIR NAMES graphite2/Font.h REQUIRED)
find_library(GRAPHITE2_LIBRARY NAMES graphite2 REQUIRED)

add_executable(main main.cpp)
target_include_directories(main PRIVATE "${GRAPHITE2_INCLUDE_DIR}")
target_link_libraries(main PRIVATE "${GRAPHITE2_LIBRARY}")
