cmake_minimum_required(VERSION 3.10)
project(test)
set(CMAKE_CXX_STANDARD 11)
add_executable(main main.cpp)
# Vorbis reference encoder and decoder, low-level API
find_package(Vorbis CONFIG REQUIRED)
target_link_libraries(main PRIVATE Vorbis::vorbis)
# Audio stream decoding and basic manipulation, high-level API
find_package(Vorbis CONFIG REQUIRED)
target_link_libraries(main PRIVATE Vorbis::vorbisfile)
# Convenience API for setting up an encoding environment
find_package(Vorbis CONFIG REQUIRED)
target_link_libraries(main PRIVATE Vorbis::vorbisenc)
