cmake_minimum_required(VERSION 3.7)

project(skia-example)

set(CMAKE_CXX_STANDARD 17)

add_executable(legacy convert-to-nia.cpp)
find_package(skia CONFIG REQUIRED)
target_link_libraries(legacy PRIVATE skia)

add_executable(main convert-to-nia.cpp)
find_package(unofficial-skia CONFIG REQUIRED)
target_link_libraries(main PRIVATE unofficial::skia::skia)

if("skparagraph" IN_LIST FEATURES)
    target_link_libraries(main PRIVATE unofficial::skia::modules::skparagraph)
endif()
