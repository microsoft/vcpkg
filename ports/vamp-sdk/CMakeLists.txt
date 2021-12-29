cmake_minimum_required(VERSION 3.8)
project(vamp-cmake)

find_package(SndFile REQUIRED)

set(VAMP_HEADERS ${CMAKE_CURRENT_SOURCE_DIR}/vamp/vamp.h)

set(SDK_HEADERS
    ${CMAKE_CURRENT_SOURCE_DIR}/vamp-sdk/Plugin.h
    ${CMAKE_CURRENT_SOURCE_DIR}/vamp-sdk/PluginAdapter.h
    ${CMAKE_CURRENT_SOURCE_DIR}/vamp-sdk/PluginBase.h
    ${CMAKE_CURRENT_SOURCE_DIR}/vamp-sdk/RealTime.h
    ${CMAKE_CURRENT_SOURCE_DIR}/vamp-sdk/FFT.h
    ${CMAKE_CURRENT_SOURCE_DIR}/vamp-sdk/plugguard.h
    ${CMAKE_CURRENT_SOURCE_DIR}/vamp-sdk/vamp-sdk.h)

set(SDK_SRC
    ${CMAKE_CURRENT_SOURCE_DIR}/src/vamp-sdk/acsymbols.c
    ${CMAKE_CURRENT_SOURCE_DIR}/src/vamp-sdk/FFT.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/src/vamp-sdk/PluginAdapter.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/src/vamp-sdk/RealTime.cpp)

set(HOST_SDK_HEADERS
    ${CMAKE_CURRENT_SOURCE_DIR}/vamp-hostsdk/Plugin.h
    ${CMAKE_CURRENT_SOURCE_DIR}/vamp-hostsdk/PluginBase.h
    ${CMAKE_CURRENT_SOURCE_DIR}/vamp-hostsdk/PluginHostAdapter.h
    ${CMAKE_CURRENT_SOURCE_DIR}/vamp-hostsdk/RealTime.h
    ${CMAKE_CURRENT_SOURCE_DIR}/vamp-hostsdk/PluginBufferingAdapter.h
    ${CMAKE_CURRENT_SOURCE_DIR}/vamp-hostsdk/PluginChannelAdapter.h
    ${CMAKE_CURRENT_SOURCE_DIR}/vamp-hostsdk/PluginInputDomainAdapter.h
    ${CMAKE_CURRENT_SOURCE_DIR}/vamp-hostsdk/PluginLoader.h
    ${CMAKE_CURRENT_SOURCE_DIR}/vamp-hostsdk/PluginSummarisingAdapter.h
    ${CMAKE_CURRENT_SOURCE_DIR}/vamp-hostsdk/PluginWrapper.h
    ${CMAKE_CURRENT_SOURCE_DIR}/vamp-hostsdk/hostguard.h
    ${CMAKE_CURRENT_SOURCE_DIR}/vamp-hostsdk/host-c.h
    ${CMAKE_CURRENT_SOURCE_DIR}/vamp-hostsdk/vamp-hostsdk.h)

set(HOST_SDK_SRC
    ${CMAKE_CURRENT_SOURCE_DIR}/src/vamp-hostsdk/acsymbols.c
    ${CMAKE_CURRENT_SOURCE_DIR}/src/vamp-hostsdk/Files.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/src/vamp-hostsdk/PluginBufferingAdapter.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/src/vamp-hostsdk/PluginChannelAdapter.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/src/vamp-hostsdk/PluginHostAdapter.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/src/vamp-hostsdk/PluginInputDomainAdapter.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/src/vamp-hostsdk/PluginLoader.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/src/vamp-hostsdk/PluginSummarisingAdapter.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/src/vamp-hostsdk/PluginWrapper.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/src/vamp-hostsdk/RealTime.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/src/vamp-hostsdk/host-c.cpp)

if(BUILD_SHARED_LIBS)
  if(MSVC)
    set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON)
  endif()
endif()

add_library(vamp-sdk ${SDK_SRC} ${SDK_HEADERS})
add_library(vamp-hostsdk ${HOST_SDK_SRC} ${HOST_SDK_HEADERS})

message(${SDK_HEADERS})

set_target_properties(vamp-sdk PROPERTIES PUBLIC_HEADER "${SDK_HEADERS}")
set_target_properties(vamp-hostsdk PROPERTIES PUBLIC_HEADER
                                              "${HOST_SDK_HEADERS}")

# The Visual Studio project files upstream intentionally output different
# library file names than autotools.
# https://github.com/tenacityteam/tenacity/pull/577#discussion_r702328284
if(WIN32)
    set_target_properties(vamp-sdk PROPERTIES OUTPUT_NAME VampPluginSDK)
    set_target_properties(vamp-hostsdk PROPERTIES OUTPUT_NAME VampHostSDK)
endif()

set_property(TARGET vamp-sdk PROPERTY CXX_STANDARD 11)
set_property(TARGET vamp-hostsdk PROPERTY CXX_STANDARD 11)

include_directories(${CMAKE_CURRENT_SOURCE_DIR})
add_definitions(-D_LIB -D_USE_MATH_DEFINES)

target_link_libraries(vamp-hostsdk PUBLIC SndFile::sndfile)

target_link_libraries(vamp-sdk PUBLIC SndFile::sndfile)

install(
  TARGETS vamp-hostsdk vamp-sdk
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
  PUBLIC_HEADER DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}")

if(NOT DISABLE_INSTALL_HEADERS)
  install(
    DIRECTORY vamp-hostsdk/
    DESTINATION include/vamp-hostsdk
    FILES_MATCHING
    PATTERN "*.h"
    PATTERN "*_priv.h" EXCLUDE
    PATTERN "config.h" EXCLUDE)
  install(
    DIRECTORY vamp-sdk/
    DESTINATION include/vamp-sdk
    FILES_MATCHING
    PATTERN "*.h"
    PATTERN "*_priv.h" EXCLUDE
    PATTERN "config.h" EXCLUDE)
  install(
    DIRECTORY vamp/
    DESTINATION include/vamp
    FILES_MATCHING
    PATTERN "*.h"
    PATTERN "*_priv.h" EXCLUDE
    PATTERN "config.h" EXCLUDE)
endif()
