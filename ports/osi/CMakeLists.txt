cmake_minimum_required(VERSION 3.11)

project(Osi LANGUAGES C CXX)

set(PROJECT_VERSION 0.107.9)
set(PROJECT_VERSION_MAJOR 0)
set(PROJECT_VERSION_MINOR 107)
set(PROJECT_VERSION_PATCH 9)

set(CMAKE_CXX_STANDARD 14)

# Introduce variables: * CMAKE_INSTALL_LIBDIR * CMAKE_INSTALL_BINDIR
include(GNUInstallDirs)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/bin)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/lib)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/lib)

set(INSTALL_BIN_DIR      "bin"                    CACHE PATH "Path where exe and dll will be installed")
set(INSTALL_LIB_DIR      "lib"                    CACHE PATH "Path where lib will be installed")
set(INSTALL_INCLUDE_DIR  "include"                CACHE PATH "Path where headers will be installed")
set(INSTALL_CMAKE_DIR    "share/${PROJECT_NAME}"  CACHE PATH "Path where cmake configs will be installed")

if(MSVC)
  set(
    CMAKE_CXX_FLAGS
    "${CMAKE_CXX_FLAGS} /bigobj /MP /wd4996 /wd4819 /wd4251 /wd4267 /wd4244 /wd4275"
    )
endif(MSVC)
if(APPLE)
  set(
    CMAKE_CXX_FLAGS
    "${CMAKE_CXX_FLAGS} -Wno-inconsistent-missing-override -Wno-unused-command-line-argument -Wno-unused-result -Wno-exceptions"
    )
  set(CMAKE_OSX_DEPLOYMENT_TARGET "10.9"
      CACHE STRING "Minimum OS X deployment version")
endif(APPLE)

include(CMakePackageConfigHelpers)

set(config_install_dir "${INSTALL_CMAKE_DIR}")
set(generated_dir "${CMAKE_CURRENT_BINARY_DIR}/generated")
# Configuration
set(version_config "${generated_dir}/${PROJECT_NAME}ConfigVersion.cmake")
set(project_config "${generated_dir}/${PROJECT_NAME}Config.cmake")
set(TARGETS_EXPORT_NAME "${PROJECT_NAME}Targets")
set(namespace "Coin::")

find_package(CoinUtils REQUIRED)

file(GLOB OSI_SOURCES Osi/src/Osi/*.hpp Osi/src/Osi/*.cpp)

add_library(${PROJECT_NAME} ${OSI_SOURCES})

target_include_directories(${PROJECT_NAME} PUBLIC $<INSTALL_INTERFACE:include/coin> $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/Osi/src/Osi>)

if(MSVC)
  target_compile_definitions(${PROJECT_NAME} PRIVATE _CRT_SECURE_NO_WARNINGS)
endif()
target_compile_definitions(${PROJECT_NAME} PRIVATE HAVE_CMATH)

target_link_libraries(${PROJECT_NAME} PRIVATE Coin::CoinUtils)

install(TARGETS ${PROJECT_NAME}
        EXPORT "${TARGETS_EXPORT_NAME}"
        LIBRARY DESTINATION lib
        ARCHIVE DESTINATION lib
        RUNTIME DESTINATION bin
        INCLUDES
        DESTINATION include)

install(DIRECTORY Osi/src/Osi/
        DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/coin
        FILES_MATCHING
        PATTERN "*.h"
        PATTERN "*.hpp"
        PATTERN "config_default.h" EXCLUDE)

# Configure '<PROJECT-NAME>ConfigVersion.cmake' Use: * PROJECT_VERSION
write_basic_package_version_file("${version_config}"
                                 COMPATIBILITY SameMajorVersion)

# Configure '<PROJECT-NAME>Config.cmake' Use variables: * TARGETS_EXPORT_NAME * PROJECT_NAME
configure_package_config_file("Config.cmake.in"
                              "${project_config}"
                              INSTALL_DESTINATION
                              "${config_install_dir}")

install(FILES "${project_config}" "${version_config}"
        DESTINATION "${config_install_dir}")

install(EXPORT "${TARGETS_EXPORT_NAME}"
        NAMESPACE "${namespace}"
        DESTINATION "${config_install_dir}")
