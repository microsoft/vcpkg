cmake_minimum_required(VERSION 3.15)
project(rohanmohapatra-hdbscan LANGUAGES CXX)

# Create a static library
add_library(rohanmohapatra-hdbscan STATIC
    HDBSCAN-CPP/HdbscanStar/cluster.cpp
    HDBSCAN-CPP/HdbscanStar/hdbscanAlgorithm.cpp
    HDBSCAN-CPP/HdbscanStar/hdbscanConstraint.cpp
    HDBSCAN-CPP/HdbscanStar/outlierScore.cpp
    HDBSCAN-CPP/HdbscanStar/undirectedGraph.cpp
    HDBSCAN-CPP/Utils/bitSet.cpp
)

# Require C++17
target_compile_features(rohanmohapatra-hdbscan PUBLIC cxx_std_17)

# Include directories (PRIVATE for Utils, PUBLIC for HdbscanStar)
target_include_directories(rohanmohapatra-hdbscan PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/HDBSCAN-CPP/Utils>
    $<INSTALL_INTERFACE:include/Utils>
)

target_include_directories(rohanmohapatra-hdbscan PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/HDBSCAN-CPP/HdbscanStar>
    $<INSTALL_INTERFACE:include/HdbscanStar>
)

# Installation
include(GNUInstallDirs)

install(TARGETS rohanmohapatra-hdbscan
    EXPORT rohanmohapatra-hdbscanTargets
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
    RUNTIME DESTINATION bin
)

# Install headers (use DIRECTORY instead of FILES for scalability)
install(DIRECTORY ${PROJECT_SOURCE_DIR}/HDBSCAN-CPP/HdbscanStar/
    DESTINATION include/HdbscanStar
    FILES_MATCHING PATTERN "*.hpp"
)

install(DIRECTORY ${PROJECT_SOURCE_DIR}/HDBSCAN-CPP/Utils/
    DESTINATION include/Utils
    FILES_MATCHING PATTERN "*.hpp"
)

# Export CMake package
install(EXPORT rohanmohapatra-hdbscanTargets
    FILE rohanmohapatra-hdbscanConfig.cmake
    NAMESPACE rohanmohapatra-hdbscan::
    DESTINATION share/rohanmohapatra-hdbscan
)