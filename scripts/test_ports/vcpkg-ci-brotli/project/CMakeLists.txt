cmake_minimum_required(VERSION 3.10)
project(test)
set(CMAKE_CXX_STANDARD 11)
add_executable(main main.cpp)
find_package(unofficial-brotli CONFIG REQUIRED)
# Brotli decoder library
target_link_libraries(main PRIVATE unofficial::brotli::brotlidec)
# Brotli encoder library
target_link_libraries(main PRIVATE unofficial::brotli::brotlienc)
