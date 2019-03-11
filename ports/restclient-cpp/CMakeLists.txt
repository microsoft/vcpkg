
cmake_minimum_required(VERSION 3.10.0)

project(restclient-cpp
  VERSION 0.5.0
  DESCRIPTION "REST client for C++"
  HOMEPAGE_URL "http://code.mrtazz.com/restclient-cpp"
)
set(restclient-cpp_VENDOR "d@unwiredcouch.com")
set(PROJECT_VENDOR "${restclient-cpp_VENDOR}")

message(STATUS "Configured for: ${CMAKE_BUILD_TYPE}")
add_custom_target(BeginMessage ALL
    ${CMAKE_COMMAND} -E cmake_echo_color --white "Compiling for: $<CONFIG>"
    COMMENT "Compile Info" )

set(CMAKE_DEBUG_POSTFIX d)

set(CMAKE_CXX_STANDARD 11)

list(APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake/modules")


if(POLICY CMP0074)
  cmake_policy(SET CMP0074 NEW)
endif()

include(CheckIncludeFiles)

find_package(GTest)
if(GTEST_FOUND)
set(Gtest_FOUND TRUE)
endif()
if(GTest_FOUND)
include(GoogleTest)
endif()

find_package(Threads REQUIRED)
find_package(CURL REQUIRED)
find_package(jsoncpp)

add_library(restclient-cpp STATIC
  source/restclient.cc
  source/connection.cc
  source/helpers.cc
)
set_property(TARGET restclient-cpp PROPERTY SOVERSION 2.1.1)

target_compile_features(restclient-cpp PUBLIC cxx_std_11)

list(APPEND restclient-cpp_PUBLIC_HEADERS
  include/restclient-cpp/restclient.h
  "${CMAKE_CURRENT_BINARY_DIR}/include/restclient-cpp/version.h"
  include/restclient-cpp/connection.h
  include/restclient-cpp/helpers.h
)
# target_sources(restclient-cpp PRIVATE ${restclient-cpp_PUBLIC_HEADERS})
set_property(TARGET restclient-cpp PROPERTY
  PUBLIC_HEADER ${restclient-cpp_PUBLIC_HEADERS})
target_include_directories(restclient-cpp PRIVATE include)

if(NOT EXISTS "${CMAKE_CURRENT_BINARY_DIR}/version.h.in")
file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/version.h.in" [=[
#ifndef INCLUDE_RESTCLIENT_CPP_VERSION_H_
#define INCLUDE_RESTCLIENT_CPP_VERSION_H_
#define RESTCLIENT_VERSION "@restclient-cpp_VERSION@"
#endif  // INCLUDE_RESTCLIENT_CPP_VERSION_H_
]=])
endif()
configure_file("${CMAKE_CURRENT_BINARY_DIR}/version.h.in"
  "${CMAKE_CURRENT_BINARY_DIR}/include/restclient-cpp/version.h")
target_include_directories(restclient-cpp PRIVATE "${CMAKE_CURRENT_BINARY_DIR}/include")

target_link_libraries(restclient-cpp
  PUBLIC CURL::libcurl
  PUBLIC Threads::Threads
)

set(INCLUDE_INSTALL_DIR "include/restclient-cpp" )
set(CONFIG_INSTALL_DIR "lib/cmake/restclient-cpp" )
set(RUNTIME_INSTALL_DIR "bin" )
set(LIB_INSTALL_DIR "lib" )
set(DATA_INSTALL_DIR "share/restclient-cpp" )

install(TARGETS restclient-cpp EXPORT restclient-cppTargets
  PUBLIC_HEADER DESTINATION ${INCLUDE_INSTALL_DIR}
  RUNTIME DESTINATION ${RUNTIME_INSTALL_DIR}
  LIBRARY DESTINATION ${LIB_INSTALL_DIR}
  ARCHIVE DESTINATION ${LIB_INSTALL_DIR}
  RESOURCE DESTINATION ${DATA_INSTALL_DIR}
)

include(CMakePackageConfigHelpers)
file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}Config.cmake.in"
  "@PACKAGE_INIT@\ninclude(\${CMAKE_CURRENT_LIST_DIR}/\@PROJECT_NAME\@Targets.cmake)\n")
configure_package_config_file(
  ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}Config.cmake.in
    ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}Config.cmake
  INSTALL_DESTINATION
    ${CMAKE_INSTALL_PREFIX}/${CONFIG_INSTALL_DIR}
  PATH_VARS
    INCLUDE_INSTALL_DIR
    CONFIG_INSTALL_DIR
    RUNTIME_INSTALL_DIR
    LIB_INSTALL_DIR
    DATA_INSTALL_DIR
)
  
write_basic_package_version_file(
  "${CMAKE_CURRENT_BINARY_DIR}/restclient-cppConfigVersion.cmake"
  COMPATIBILITY
    SameMajorVersion
)

# export targets for find_package config mode
install(EXPORT restclient-cppTargets DESTINATION ${CONFIG_INSTALL_DIR})

install(
  FILES
    ${CMAKE_CURRENT_BINARY_DIR}/restclient-cppConfig.cmake
    ${CMAKE_CURRENT_BINARY_DIR}/restclient-cppConfigVersion.cmake
  DESTINATION
    ${CMAKE_INSTALL_PREFIX}/${CONFIG_INSTALL_DIR}
)

if(Gtest_FOUND AND jsoncpp_FOUND)

enable_testing()


add_executable(test-program
  vendor/jsoncpp-0.10.5/dist/jsoncpp.cpp
  test/tests.cpp
  test/test_restclient.cc
  test/test_connection.cc
)
target_include_directories(test-program
  PRIVATE include
  PRIVATE vendor/jsoncpp-0.10.5/dist
  PRIVATE "${CMAKE_CURRENT_BINARY_DIR}/include")

target_link_libraries(test-program
  PUBLIC restclient-cpp
  PUBLIC GTest::GTest
)
gtest_discover_tests(test-program
  WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
  EXTRA_ARGS -VV
)

endif()


# TODO: Setup ctest here for valgrind and CI

# TODO: Setup cpack here for automatic packaging.
#       Note most of the work is already done above due to use of properties and install commands.

include(FeatureSummary)
feature_summary(WHAT ALL)


