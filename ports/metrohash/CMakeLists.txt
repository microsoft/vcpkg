cmake_minimum_required(VERSION 3.14)
project(metrohash LANGUAGES CXX)
set(CMAKE_CXX_STANDARD 17)

add_library(metrohash
            src/metrohash64.cpp
            src/metrohash128.cpp
            )
list(APPEND metro_headers src/metrohash.h src/metrohash64.h src/metrohash128.h)

if(NOT ANDROID AND NOT IOS)
    list(APPEND metro_headers src/metrohash128crc.h)
    target_sources(metrohash PRIVATE src/metrohash128crc.cpp)
    if(CMAKE_CXX_COMPILER_ID MATCHES Clang)
        target_compile_options(metrohash PRIVATE -msse4.2)
    endif()
endif()
if(CMAKE_CXX_COMPILER_ID MATCHES GNU)
    target_compile_options(metrohash PRIVATE -march=native)
endif()

set_target_properties(metrohash PROPERTIES
                      PUBLIC_HEADER "${metro_headers}"
                      )

include(CMakePackageConfigHelpers)

set(generated_dir "${CMAKE_CURRENT_BINARY_DIR}/generated")
set(project_config "${generated_dir}/${PROJECT_NAME}Config.cmake")
set(config_install_dir "lib/cmake/${PROJECT_NAME}")
set(TARGETS_EXPORT_NAME "${PROJECT_NAME}Targets")
set(namespace "${PROJECT_NAME}::")

configure_package_config_file(
        "${CMAKE_SOURCE_DIR}/cmake/Config.cmake.in"
        "${project_config}"
        INSTALL_DESTINATION "${config_install_dir}"
)
#Installation
install(TARGETS metrohash
        EXPORT "${TARGETS_EXPORT_NAME}"
        LIBRARY DESTINATION "lib"
        ARCHIVE DESTINATION "lib"
        PUBLIC_HEADER DESTINATION "include")

install(
        FILES "${project_config}"
        DESTINATION "${config_install_dir}"
)
install(EXPORT "${TARGETS_EXPORT_NAME}"
        NAMESPACE "${namespace}"
        DESTINATION "${config_install_dir}"
        )
