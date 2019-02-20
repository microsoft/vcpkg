cmake_minimum_required(VERSION 3.11)

project(Osi LANGUAGES C CXX)

set(PROJECT_VERSION 0.107.9)
set(PROJECT_VERSION_MAJOR 0)
set(PROJECT_VERSION_MINOR 107)
set(PROJECT_VERSION_PATCH 9)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/bin)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/lib)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/lib)
set(CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH};${CMAKE_CURRENT_SOURCE_DIR}/cmake")
if(BUILD_SHARED_LIBS AND MSVC)
  set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON)
endif(BUILD_SHARED_LIBS AND MSVC)
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

set_property(GLOBAL PROPERTY USE_FOLDERS ON)

# options
option(BUILD_SHARED_LIBS "" ON)

#
# 设置用于 install 的变量
#
# Introduce variables: * CMAKE_INSTALL_LIBDIR * CMAKE_INSTALL_BINDIR
include(GNUInstallDirs)

# Include module with fuction 'write_basic_package_version_file'
include(CMakePackageConfigHelpers)

# Layout. This works for all platforms: * <prefix>/lib*/cmake/<PROJECT-NAME> *
# <prefix>/lib*/ * <prefix>/include/
set(config_install_dir "${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME}")
set(generated_dir "${CMAKE_CURRENT_BINARY_DIR}/generated")
# Configuration
set(version_config "${generated_dir}/${PROJECT_NAME}ConfigVersion.cmake")
set(project_config "${generated_dir}/${PROJECT_NAME}Config.cmake")
set(TARGETS_EXPORT_NAME "${PROJECT_NAME}Targets")
set(namespace "Coin::")

# Packages
find_package(CoinUtils REQUIRED)

# Add sources
include_directories(Osi/src/Osi)

file(GLOB OSI_SOURCES Osi/src/Osi/*.hpp Osi/src/Osi/*.cpp)

add_library(${PROJECT_NAME} ${OSI_SOURCES})

target_include_directories(${PROJECT_NAME}
                           PUBLIC $<INSTALL_INTERFACE:include/coin>)
target_compile_definitions(${PROJECT_NAME}
                           PUBLIC
                           $<INSTALL_INTERFACE:-DHAVE_CMATH>
                           $<INSTALL_INTERFACE:-D_CRT_SECURE_NO_WARNINGS>)
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

#
# Install Libraries
#
# Configure '<PROJECT-NAME>ConfigVersion.cmake' Use: * PROJECT_VERSION
write_basic_package_version_file("${version_config}"
                                 COMPATIBILITY SameMajorVersion)

# Configure '<PROJECT-NAME>Config.cmake' Use variables: * TARGETS_EXPORT_NAME *
# PROJECT_NAME
configure_package_config_file("Config.cmake.in"
                              "${project_config}"
                              INSTALL_DESTINATION
                              "${config_install_dir}")

# Config * <prefix>/lib/cmake/Foo/FooConfig.cmake *
# <prefix>/lib/cmake/Foo/FooConfigVersion.cmake
install(FILES "${project_config}" "${version_config}"
        DESTINATION "${config_install_dir}")

# Config * <prefix>/lib/cmake/Foo/FooTargets.cmake
install(EXPORT "${TARGETS_EXPORT_NAME}"
        NAMESPACE "${namespace}"
        DESTINATION "${config_install_dir}")
