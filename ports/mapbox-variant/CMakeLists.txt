cmake_minimum_required(VERSION 3.16)
project(variant-library VERSION 1.1.3 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

include(GNUInstallDirs)
include(CMakePackageConfigHelpers)

find_package(Boost REQUIRED COMPONENTS timer system chrono)

add_library(variant INTERFACE)
add_library(variant::variant ALIAS variant)

target_include_directories(variant
    INTERFACE
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
        $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)

target_compile_features(variant INTERFACE cxx_std_11)

if(APPLE)
    target_link_options(variant INTERFACE "-framework CoreFoundation")
endif()

if(UNIX AND NOT APPLE)
    target_link_libraries(variant INTERFACE rt)
endif()

install(DIRECTORY "include/mapbox"
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
    FILES_MATCHING PATTERN "*.hpp"
)

install(TARGETS variant
    EXPORT variant-targets
    INCLUDES DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
)

install(EXPORT variant-targets
    FILE variant-targets.cmake
    NAMESPACE variant::
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/variant
)

configure_package_config_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/variant-config.cmake.in"
    "${CMAKE_CURRENT_BINARY_DIR}/variant-config.cmake"
    INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/variant
    PATH_VARS CMAKE_INSTALL_INCLUDEDIR
)

write_basic_package_version_file(
    "${CMAKE_CURRENT_BINARY_DIR}/variant-config-version.cmake"
    VERSION ${PROJECT_VERSION}
    COMPATIBILITY SameMajorVersion
)

install(FILES
    "${CMAKE_CURRENT_BINARY_DIR}/variant-config.cmake"
    "${CMAKE_CURRENT_BINARY_DIR}/variant-config-version.cmake"
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/variant
)
