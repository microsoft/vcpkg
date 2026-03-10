cmake_minimum_required(VERSION 3.16)
project(vsgqt-test)

set(CMAKE_CXX_STANDARD 17)

find_package(vsgQt CONFIG REQUIRED)

add_executable(vsgqtviewer "${SOURCE_PATH}/examples/vsgqtviewer/main.cpp")
target_link_libraries(vsgqtviewer PRIVATE vsgQt::vsgQt)

if (USE_VSGXCHANGE)
    find_package(vsgXchange CONFIG REQUIRED)
    target_compile_definitions(vsgqtviewer PRIVATE vsgXchange_FOUND)
    target_link_libraries(vsgqtviewer PRIVATE vsgXchange::vsgXchange)
endif()
