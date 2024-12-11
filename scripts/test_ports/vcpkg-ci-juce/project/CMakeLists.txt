cmake_minimum_required(VERSION 3.29)
project(juce-test VERSION 1 LANGUAGES C CXX)

set(CMAKE_CXX_STANDARD 11)

find_package(JUCE CONFIG REQUIRED)

juce_add_console_app(main PRODUCT_NAME "vcpkg-ci-juce")
target_sources(main PRIVATE main.cpp)
target_link_libraries(main PRIVATE juce::juce_core)
