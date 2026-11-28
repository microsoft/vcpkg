cmake_minimum_required(VERSION 3.14)
project(ydlidar_sdk C CXX)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

include(GNUInstallDirs)
include(CMakePackageConfigHelpers)

if(NOT YDLIDAR_SDK_VERSION)
    message(FATAL_ERROR "YDLIDAR_SDK_VERSION must be set")
endif()

configure_file(ydlidar_config.h.in "${CMAKE_CURRENT_BINARY_DIR}/ydlidar_config.h")

file(GLOB YDLIDAR_SOURCES
    core/base/*.cpp
    core/common/*.cpp
    core/network/*.cpp
    core/serial/*.cpp
    src/*.cpp
    src/filters/*.cpp
)
if(WIN32)
    file(GLOB YDLIDAR_PLATFORM_SOURCES core/serial/impl/windows/*.cpp)
else()
    file(GLOB YDLIDAR_PLATFORM_SOURCES core/serial/impl/unix/*.cpp core/serial/impl/unix/*.c)
endif()

add_library(ydlidar_sdk ${YDLIDAR_SOURCES} ${YDLIDAR_PLATFORM_SOURCES})

target_include_directories(ydlidar_sdk
    PRIVATE
        "${CMAKE_CURRENT_SOURCE_DIR}/core/base"
        "${CMAKE_CURRENT_SOURCE_DIR}/core"
        "${CMAKE_CURRENT_SOURCE_DIR}/core/common"
        "${CMAKE_CURRENT_SOURCE_DIR}/core/math"
        "${CMAKE_CURRENT_SOURCE_DIR}/core/network"
        "${CMAKE_CURRENT_SOURCE_DIR}/core/serial"
        "${CMAKE_CURRENT_SOURCE_DIR}/core/serial/impl/$<IF:$<BOOL:${WIN32}>,windows,unix>"
        "${CMAKE_CURRENT_SOURCE_DIR}/src/filters"
    PUBLIC
        "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>"
        "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src>"
        "$<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}>"
        "$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/ydlidar_sdk>"
        "$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/ydlidar_sdk/src>"
)

if(WIN32)
    target_compile_definitions(ydlidar_sdk PRIVATE WIN32_LEAN_AND_MEAN NOMINMAX)
    target_link_libraries(ydlidar_sdk PUBLIC advapi32 winmm setupapi ws2_32)
else()
    find_package(Threads REQUIRED)
    target_link_libraries(ydlidar_sdk PUBLIC Threads::Threads)
    if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
        target_link_libraries(ydlidar_sdk PUBLIC rt)
    endif()
endif()

if(MSVC)
    target_compile_options(ydlidar_sdk PRIVATE /utf-8)
endif()

install(TARGETS ydlidar_sdk
    EXPORT unofficial-ydlidar-sdk-targets
    ARCHIVE DESTINATION "${CMAKE_INSTALL_LIBDIR}"
    LIBRARY DESTINATION "${CMAKE_INSTALL_LIBDIR}"
    RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}"
)

install(DIRECTORY core src
    DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}/ydlidar_sdk"
    FILES_MATCHING PATTERN "*.h"
)
install(FILES "${CMAKE_CURRENT_BINARY_DIR}/ydlidar_config.h"
    DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}/ydlidar_sdk"
)

install(EXPORT unofficial-ydlidar-sdk-targets
    NAMESPACE unofficial::ydlidar-sdk::
    DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}/unofficial-ydlidar-sdk"
)
configure_package_config_file(
    unofficial-ydlidar-sdk-config.cmake.in
    "${CMAKE_CURRENT_BINARY_DIR}/unofficial-ydlidar-sdk-config.cmake"
    INSTALL_DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}/unofficial-ydlidar-sdk"
)
write_basic_package_version_file(
    "${CMAKE_CURRENT_BINARY_DIR}/unofficial-ydlidar-sdk-config-version.cmake"
    VERSION "${YDLIDAR_SDK_VERSION}"
    COMPATIBILITY SameMinorVersion
)
install(FILES
    "${CMAKE_CURRENT_BINARY_DIR}/unofficial-ydlidar-sdk-config.cmake"
    "${CMAKE_CURRENT_BINARY_DIR}/unofficial-ydlidar-sdk-config-version.cmake"
    DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}/unofficial-ydlidar-sdk"
)
