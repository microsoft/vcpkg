cmake_minimum_required(VERSION 3.7)
project(mimalloc C CXX)

find_package(PkgConfig REQUIRED)

set(CMAKE_FIND_DEBUG_MODE 1)

# Validate CMake config

find_package(mimalloc CONFIG REQUIRED)

find_file(mimalloc_h NAMES mimalloc.h PATHS "${MIMALLOC_INCLUDE_DIR}" NO_DEFAULT_PATH REQUIRED)
find_library(mimalloc_lib NAMES mimalloc mimalloc-debug mimalloc-secure mimalloc-secure-debug PATHS "${MIMALLOC_LIBRARY_DIR}" NO_DEFAULT_PATH REQUIRED)

add_executable(main-cmake main.c)
if(BUILD_SHARED_LIBS)
    target_link_libraries(main-cmake PRIVATE $<TARGET_NAME:mimalloc>)
else()
    target_link_libraries(main-cmake PRIVATE $<TARGET_NAME:mimalloc-static>)
endif()

# Validate pkgconfig

pkg_check_modules(PC_MIMALLOC mimalloc IMPORTED_TARGET REQUIRED)

# pkgconfig doesn't carry C++ linkage
configure_file("${CMAKE_SOURCE_DIR}/main.c" "${CMAKE_BINARY_DIR}/main.cpp" COPY_ONLY)
add_executable(main-pc "${CMAKE_BINARY_DIR}/main.cpp")
target_link_libraries(main-pc PRIVATE PkgConfig::PC_MIMALLOC)

# Runtime test

if(NOT VCPKG_CROSS_COMPILING)
    add_custom_target(run-main-cmake ALL
        COMMAND "${CMAKE_COMMAND}" -E env MIMALLOC_VERBOSE=1 $<TARGET_FILE:main-cmake>
    )
endif()

# Deplyoment

install(TARGETS main-cmake)
