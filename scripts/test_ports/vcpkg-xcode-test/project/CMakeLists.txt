cmake_minimum_required(VERSION 3.4)
project(xcode-test LANGUAGES CXX)


add_library(xcode-test STATIC xcode-test.cpp)

install(FILES xcode-test.h DESTINATION include)

install(TARGETS xcode-test
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)