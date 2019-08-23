cmake_minimum_required(VERSION 3.9)
project(Box2d CXX)

file(GLOB_RECURSE SOURCES Box2D/Box2D/*.cpp)

add_library(Box2D ${SOURCES})
target_include_directories(Box2D PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/Box2D> $<INSTALL_INTERFACE:include>)

install(TARGETS Box2D
    EXPORT unofficial-box2d-targets
    RUNTIME DESTINATION bin
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
)

install(
    EXPORT unofficial-box2d-targets
    FILE unofficial-box2d-config.cmake
    NAMESPACE unofficial::box2d::
    DESTINATION share/unofficial-box2d
)
