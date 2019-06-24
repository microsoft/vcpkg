cmake_minimum_required(VERSION 3.11)

project(CoinUtils LANGUAGES C CXX)

set(PROJECT_VERSION 2.10.14)
set(PROJECT_VERSION_MAJOR 2)
set(PROJECT_VERSION_MINOR 10)
set(PROJECT_VERSION_PATCH 14)

set(CMAKE_CXX_STANDARD 14)

set(INSTALL_BIN_DIR      "bin"                      CACHE PATH "Path where exe and dll will be installed")
set(INSTALL_LIB_DIR      "lib"                      CACHE PATH "Path where lib will be installed")
set(INSTALL_INCLUDE_DIR  "include/Coin"             CACHE PATH "Path where headers will be installed")
set(INSTALL_CMAKE_DIR    "share/coinutils"          CACHE PATH "Path where cmake configs will be installed")

# Make relative paths absolute (needed later on)
set(RELATIVE_INSTALL_INCLUDE_DIR ${INSTALL_INCLUDE_DIR})
foreach(p LIB BIN INCLUDE CMAKE)
  set(var INSTALL_${p}_DIR)
  if(NOT IS_ABSOLUTE "${${var}}")
    set(${var} "${CMAKE_INSTALL_PREFIX}/${${var}}")
  endif()
endforeach()

if(MSVC)
  set(
    CMAKE_CXX_FLAGS
    "${CMAKE_CXX_FLAGS} /bigobj /MP /wd4996 /wd4819 /wd4251 /wd4267 /wd4244 /wd4275"
    )
endif()

if(APPLE)
  set(
    CMAKE_CXX_FLAGS
    "${CMAKE_CXX_FLAGS} -Wno-inconsistent-missing-override -Wno-unused-command-line-argument -Wno-unused-result -Wno-exceptions"
    )
  set(CMAKE_OSX_DEPLOYMENT_TARGET "10.9"
      CACHE STRING "Minimum OS X deployment version")
endif()

include(CheckIncludeFileCXX)
include(CheckIncludeFile)
check_include_file_cxx("cmath"    HAVE_CMATH)
check_include_file_cxx("cfloat"    HAVE_CFLOAT)
if(NOT HAVE_CMATH OR NOT HAVE_CFLOAT)
    message(FATAL_ERROR "Missing necessary include files, like cmath or cfloat")
endif()

file(GLOB UTILS_SOURCES
          CoinUtils/src/*.hpp
          CoinUtils/src/*.cpp
          CoinUtils/src/*.h)

add_library(${PROJECT_NAME} ${UTILS_SOURCES})

target_include_directories(${PROJECT_NAME} PUBLIC $<INSTALL_INTERFACE:${RELATIVE_INSTALL_INCLUDE_DIR}> $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/CoinUtils/src>)

if(MSVC)
  target_compile_definitions(${PROJECT_NAME} PRIVATE _CRT_SECURE_NO_WARNINGS)
endif()
target_compile_definitions(${PROJECT_NAME} PRIVATE HAVE_CMATH HAVE_CFLOAT)

install(DIRECTORY CoinUtils/src/
        DESTINATION ${INSTALL_INCLUDE_DIR}
        FILES_MATCHING
        PATTERN "*.h"
        PATTERN "*.hpp")

install(TARGETS ${PROJECT_NAME}
        EXPORT "${PROJECT_NAME}Targets"
        LIBRARY DESTINATION lib
        ARCHIVE DESTINATION lib
        RUNTIME DESTINATION bin)

include(CMakePackageConfigHelpers)

set(version_config "${CMAKE_CURRENT_BINARY_DIR}/temp/${PROJECT_NAME}ConfigVersion.cmake")
set(project_config "${CMAKE_CURRENT_BINARY_DIR}/temp/${PROJECT_NAME}Config.cmake")
set(namespace "Coin::")

write_basic_package_version_file("${version_config}"
                                 COMPATIBILITY SameMajorVersion)

configure_package_config_file("Config.cmake.in"
                              "${project_config}"
                              INSTALL_DESTINATION
                              "${INSTALL_CMAKE_DIR}")

install(FILES "${project_config}" "${version_config}"
        DESTINATION "${INSTALL_CMAKE_DIR}")

install(EXPORT "${PROJECT_NAME}Targets"
        NAMESPACE "${namespace}"
        DESTINATION "${INSTALL_CMAKE_DIR}")
