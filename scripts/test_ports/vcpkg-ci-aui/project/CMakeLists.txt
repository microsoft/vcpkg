cmake_minimum_required(VERSION 3.22)
project(aui-test LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(aui CONFIG REQUIRED COMPONENTS core network crypt curl image views xml json audio updater)

add_executable(main main.cpp)
target_link_libraries(main PRIVATE aui::core aui::json aui::network aui::crypt aui::curl aui::image aui::views aui::xml aui::audio aui::updater)
