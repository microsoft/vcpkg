cmake_minimum_required(VERSION 3.30)
project(hello-imgui-test CXX)

set(CMAKE_CXX_STANDARD 17)

find_package(hello-imgui CONFIG REQUIRED)

add_executable(main main.cpp)
target_link_libraries(main PRIVATE
    hello-imgui::hello_imgui
)
