cmake_minimum_required(VERSION 3.10)
project(test)
set(CMAKE_CXX_STANDARD 11)
add_executable(main main.cpp)
find_package(OpusFile CONFIG REQUIRED)
target_link_libraries(main PRIVATE OpusFile::opusfile)
# To use the opusurl API
target_link_libraries(main PRIVATE OpusFile::opusurl)
