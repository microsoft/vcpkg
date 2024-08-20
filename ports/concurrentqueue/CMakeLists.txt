cmake_minimum_required(VERSION 3.5)
project(concurrentqueue C)

add_library(concurrentqueue INTERFACE)

target_include_directories(concurrentqueue INTERFACE $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}> $<INSTALL_INTERFACE:include>)

install(TARGETS concurrentqueue
    EXPORT concurrentqueue
)
install(EXPORT concurrentqueue FILE unofficial-concurrentqueue-targets.cmake NAMESPACE unofficial::concurrentqueue:: DESTINATION share/unofficial-concurrentqueue)
