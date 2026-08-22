# from:
# https://github.com/an-dr/abcmake/tree/4a45dea784dd98473195132a29a2980ed29b3c75/examples/hello_with_find_package
cmake_minimum_required(VERSION 3.15)
project(HelloWorld)
find_package(abcmake CONFIG REQUIRED)
add_main_component(${PROJECT_NAME})
