cmake_minimum_required(VERSION 3.10)
project(libmupdf-test C CXX)

find_package(unofficial-libmupdf REQUIRED)

add_executable(example "${SOURCE_PATH}/docs/examples/example.c")
target_link_libraries(example PRIVATE unofficial::libmupdf::libmupdf)
