cmake_minimum_required(VERSION 3.8)

project(sajson)

add_library(sajson INTERFACE)

target_compile_features(sajson INTERFACE cxx_std_11)

target_include_directories(sajson INTERFACE
    $<BUILD_INTERFACE:${CMAKE_CURRENT_LIST_DIR}/include>
    $<INSTALL_INTERFACE:include>)

install(DIRECTORY include/
    DESTINATION include
    USE_SOURCE_PERMISSIONS
    FILES_MATCHING PATTERN "*.h"
    )

install(TARGETS sajson EXPORT unofficial-sajson-config)

install(EXPORT unofficial-sajson-config
    FILE unofficial-sajson-config.cmake
    NAMESPACE unofficial::sajson::
    DESTINATION share/cmake/unofficial-sajson
    PERMISSIONS OWNER_READ OWNER_WRITE GROUP_READ WORLD_READ
)
