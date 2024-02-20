cmake_minimum_required(VERSION 3.10)
project(test)
set(CMAKE_CXX_STANDARD 11)
add_executable(main main.cpp)
find_package(WebP CONFIG REQUIRED)
# basic usage
target_link_libraries(main PRIVATE WebP::webp WebP::webpdecoder WebP::webpdemux)
# for manipulating the WebP graphics format container (port feature libwebpmux)
target_link_libraries(main PRIVATE WebP::libwebpmux)
# for sharp RGB to YUV conversion
target_link_libraries(main PRIVATE WebP::sharpyuv)
