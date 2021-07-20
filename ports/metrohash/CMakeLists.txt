cmake_minimum_required(VERSION 3.5)
project(metrohash LANGUAGES CXX)
set(CMAKE_CXX_STANDARD 11)

add_library(metrohash
            src/metrohash64.cpp
            src/metrohash128.cpp
            )
list(APPEND metro_headers src/metrohash.h src/metrohash64.h src/metrohash128.h)

include(CheckCXXSourceCompiles)
include(CheckCXXCompilerFlag)

if(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
    check_cxx_compiler_flag("-msse4.2" HAS_MSSE42)
    if(HAS_MSSE42)
        target_compile_options(metrohash PRIVATE -msse4.2)
        string(APPEND CMAKE_REQUIRED_FLAGS " -msse4.2")
    endif()
endif()

check_cxx_source_compiles(
"#include <nmmintrin.h>
int main() {
    _mm_crc32_u64(0, 0);
    return 0;
}"
HAS_mm_crc32_u64)

if(HAS_mm_crc32_u64)
    list(APPEND metro_headers src/metrohash128crc.h)
    target_sources(metrohash PRIVATE src/metrohash128crc.cpp)
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
