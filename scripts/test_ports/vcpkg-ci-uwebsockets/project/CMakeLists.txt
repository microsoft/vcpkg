cmake_minimum_required(VERSION 3.30)
project(uwebsockets-test CXX)

find_package(unofficial-uwebsockets CONFIG REQUIRED)

add_executable(main main.cxx)
target_link_libraries(main PRIVATE
    $<TARGET_NAME:unofficial::uwebsockets::uwebsockets>
)
