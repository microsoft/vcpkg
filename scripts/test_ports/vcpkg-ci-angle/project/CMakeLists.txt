cmake_minimum_required(VERSION 3.10)
project(test)
set(CMAKE_CXX_STANDARD 11)
add_executable(main main.cpp)
find_package(unofficial-angle REQUIRED CONFIG)
target_link_libraries(main PRIVATE unofficial::angle::libGLESv2)
# Or use the EGL target
find_package(unofficial-angle REQUIRED CONFIG)
target_link_libraries(main PRIVATE unofficial::angle::libEGL)
