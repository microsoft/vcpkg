#
# This file is based on https://github.com/tgockel/zookeeper-cpp/blob/a8d5f905e01893256299d5532b1836f64c89b5b9/CMakeLists.txt
# Which is licensed under Apache License 2.0
# http://www.apache.org/licenses/LICENSE-2.0
#

cmake_minimum_required(VERSION 3.5)

file(READ src/zk/config.hpp CONFIG_HPP_STR)
string(REGEX REPLACE ".*# *define +ZKPP_VERSION_MAJOR +([0-9]+).*" "\\1" ZKPP_VERSION_MAJOR "${CONFIG_HPP_STR}")
string(REGEX REPLACE ".*# *define +ZKPP_VERSION_MINOR +([0-9]+).*" "\\1" ZKPP_VERSION_MINOR "${CONFIG_HPP_STR}")
string(REGEX REPLACE ".*# *define +ZKPP_VERSION_PATCH +([0-9]+).*" "\\1" ZKPP_VERSION_PATCH "${CONFIG_HPP_STR}")

set(ZKPP_VERSION "${ZKPP_VERSION_MAJOR}.${ZKPP_VERSION_MINOR}.${ZKPP_VERSION_PATCH}")
project(zookeeper-cpp
        LANGUAGES CXX
        VERSION "${ZKPP_VERSION}"
       )
set(PROJECT_SO_VERSION "${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}")
message(STATUS "Software Version: ${ZKPP_VERSION}")

################################################################################
# CMake                                                                        #
################################################################################

cmake_policy(VERSION 3.5)
cmake_policy(SET CMP0037 OLD) # allow generation of "test" target
set(CMAKE_REQUIRED_QUIET YES) # tell check_include_file_cxx to keep quiet

list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake/modules/")

include(BuildFunctions)
include(CheckIncludeFileCXX)
include(ConfigurationSetting)
include(ListSplit)
include(GNUInstallDirs)

################################################################################
# Build Configuration                                                          #
################################################################################

find_package(Threads REQUIRED)

if (NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE "Debug")
  message(STATUS "No build type selected, default to ${CMAKE_BUILD_TYPE}")
endif()

set(VALID_BUILD_TYPES Debug Release)
if(NOT ${CMAKE_BUILD_TYPE} IN_LIST VALID_BUILD_TYPES)
  message(FATAL_ERROR "Invalid CMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}\nValid build types are: ${VALID_BUILD_TYPES}")
endif()
message(STATUS "Configuration: ${CMAKE_BUILD_TYPE}")

message(STATUS "Features:")
build_option(NAME       CODE_COVERAGE
             DOC        "Enable code coverage (turns on the test-coverage target)"
             DEFAULT    OFF
             CONFIGS_ON Debug
            )

configuration_setting(NAME    BUFFER
                      DOC     "Type to use for zk::buffer"
                      DEFAULT STD_VECTOR
                      OPTIONS
                        STD_VECTOR
                        CUSTOM
                     )

configuration_setting(NAME    FUTURE
                      DOC     "Type to use for zk::future<T> and zk::promise<T>"
                      DEFAULT STD
                      OPTIONS
                        STD
                        STD_EXPERIMENTAL
                        CUSTOM
                     )

set(CXX_STANDARD c++17
    CACHE STRING "The language standard to target for C++."
   )

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} --std=${CXX_STANDARD}")
set(CMAKE_CXX_FLAGS_DEBUG   "${CMAKE_CXX_FLAGS_DEBUG} -DZKPP_DEBUG=1")
set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -O3")

################################################################################
# External Libraries                                                           #
################################################################################

find_package(unofficial-zookeeper REQUIRED)


build_module(NAME zkpp
             PATH src/zk
             NO_RECURSE
            )

target_include_directories(zkpp PUBLIC $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}> $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src>)
target_link_libraries(zkpp PRIVATE unofficial::zookeeper::zookeeper)

install(TARGETS zkpp
    EXPORT zkpp
    RUNTIME DESTINATION bin
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
)

install(FILES ${zkpp_LIBRARY_HEADERS} DESTINATION include/zk/)

install(EXPORT zkpp DESTINATION share/zkpp/ FILE zkppConfig.cmake)
