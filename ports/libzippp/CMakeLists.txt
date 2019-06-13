cmake_minimum_required(VERSION 3.9.5)

project(libzippp)

set(PACKAGE "libzippp")
set(VERSION "0.2")

option(INSTALL_HEADERS "Install library headers" ON)
option(BUILD_TESTS "Build unit tests" OFF)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

find_package(ZLIB REQUIRED)
find_package(BZip2 REQUIRED)
find_package(LIBZIP MODULE REQUIRED)

add_library(libzippp "src/libzippp.cpp")
target_include_directories(libzippp 
  PUBLIC  
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src>
    $<INSTALL_INTERFACE:include/libzippp>
  PRIVATE
    $<BUILD_INTERFACE:${LIBZIP_INCLUDE_DIRS}>
)
target_link_libraries(libzippp PRIVATE libzip::libzip)
if (BUILD_SHARED_LIBS)
  target_compile_definitions(libzippp PUBLIC LIBZIPPP_EXPORTS)
endif()

install(
  TARGETS libzippp 
  EXPORT libzipppTargets
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib 
  RUNTIME DESTINATION bin 
)

if (INSTALL_HEADERS)
    install(FILES src/libzippp.h DESTINATION include/libzippp)
endif()

include(CMakePackageConfigHelpers)

set(PROJECT_CONFIG_FILE "${CMAKE_CURRENT_BINARY_DIR}/generated/libzipppConfig.cmake")

configure_package_config_file(
  "Config.cmake.in" 
  ${PROJECT_CONFIG_FILE} 
  INSTALL_DESTINATION "share/libzippp"
)

install(
  FILES ${PROJECT_CONFIG_FILE} 
  DESTINATION "share/libzippp"
)

install(
  EXPORT libzipppTargets
  NAMESPACE "libzippp::"
  DESTINATION "share/libzippp"
)

if (BUILD_TESTS)
  add_executable(libzippp_test "tests/tests.cpp")
  target_link_libraries(libzippp_test PRIVATE libzippp)
endif()
