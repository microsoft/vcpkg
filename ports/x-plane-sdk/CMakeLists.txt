cmake_minimum_required(VERSION 3.21)
project(x-plane-sdk LANGUAGES C CXX)

if(WIN32 OR APPLE)
  add_library(unofficial::x-plane-sdk::xplm SHARED IMPORTED)
  if(WIN32)
    set_target_properties(
      unofficial::x-plane-sdk::xplm
      PROPERTIES IMPORTED_IMPLIB "${CMAKE_CURRENT_SOURCE_DIR}/Libraries/Win/XPLM_64.lib")
    set_target_properties(
      unofficial::x-plane-sdk::xplm PROPERTIES INTERFACE_COMPILE_DEFINITIONS
                                              "-DIBM=1;-DAPL=0;-DLIN=0")
  else()
    set_target_properties(
      unofficial::x-plane-sdk::xplm
      PROPERTIES IMPORTED_LOCATION "${CMAKE_CURRENT_SOURCE_DIR}/Libraries/Mac/XPLM.framework/XPLM")
    set_target_properties(
      unofficial::x-plane-sdk::xplm PROPERTIES INTERFACE_COMPILE_DEFINITIONS
                                              "-DIBM=0;-DAPL=1;-DLIN=0")
  endif()
else()
  add_library(unofficial::x-plane-sdk::xplm INTERFACE IMPORTED)
  set_target_properties(
    unofficial::x-plane-sdk::xplm PROPERTIES INTERFACE_COMPILE_DEFINITIONS
                                            "-DIBM=0;-DAPL=0;-DLIN=1")
endif()
set_target_properties(
  unofficial::x-plane-sdk::xplm PROPERTIES INTERFACE_INCLUDE_DIRECTORIES
                                          "${CMAKE_CURRENT_SOURCE_DIR}/CHeaders/XPLM")

if(WIN32 OR APPLE)
  add_library(unofficial::x-plane-sdk::xpwidgets SHARED IMPORTED)
  if(WIN32)
    set_target_properties(
      unofficial::x-plane-sdk::xpwidgets
      PROPERTIES IMPORTED_IMPLIB "${CMAKE_CURRENT_SOURCE_DIR}/Libraries/Win/XPWidgets_64.lib")
  else()
    set_target_properties(
      unofficial::x-plane-sdk::xpwidgets
      PROPERTIES IMPORTED_LOCATION
                 "${CMAKE_CURRENT_SOURCE_DIR}/Libraries/Mac/XPWidgets.framework/XPWidgets")
  endif()
else()
  add_library(unofficial::x-plane-sdk::xpwidgets INTERFACE IMPORTED)
endif()
set_target_properties(
  unofficial::x-plane-sdk::xpwidgets PROPERTIES INTERFACE_LINK_LIBRARIES
                                               "unofficial::x-plane-sdk::xplm")
set_target_properties(
  unofficial::x-plane-sdk::xpwidgets
  PROPERTIES INTERFACE_INCLUDE_DIRECTORIES "${CMAKE_CURRENT_SOURCE_DIR}/CHeaders/Widgets")

add_library(xplm_cpp STATIC)

target_sources(
  xplm_cpp
  PRIVATE CHeaders/Wrappers/XPCBroadcaster.cpp
          CHeaders/Wrappers/XPCDisplay.cpp
          CHeaders/Wrappers/XPCListener.cpp
          CHeaders/Wrappers/XPCProcessing.cpp
          CHeaders/Wrappers/XPCWidget.cpp
          CHeaders/Wrappers/XPCWidgetAttachments.cpp)

target_include_directories(
  xplm_cpp
  INTERFACE $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/CHeaders/Wrappers>
            $<INSTALL_INTERFACE:include/x-plane-sdk/Wrappers>)

target_link_libraries(xplm_cpp PUBLIC unofficial::x-plane-sdk::xplm
                                      unofficial::x-plane-sdk::xpwidgets)

install(
  TARGETS xplm_cpp
  EXPORT xplm-targets
  ARCHIVE DESTINATION lib)

file(GLOB HEADERS "${CMAKE_CURRENT_LIST_DIR}/CHeaders/XPLM/*.h")
install(FILES ${HEADERS} DESTINATION "include/x-plane-sdk/XPLM")

file(GLOB HEADERS "${CMAKE_CURRENT_LIST_DIR}/CHeaders/Widgets/*.h")
install(FILES ${HEADERS} DESTINATION "include/x-plane-sdk/Widgets")

file(GLOB HEADERS "${CMAKE_CURRENT_LIST_DIR}/CHeaders/Wrappers/*.h")
install(FILES ${HEADERS} DESTINATION "include/x-plane-sdk/Wrappers")

include(CMakePackageConfigHelpers)
configure_package_config_file(
  "${CMAKE_CURRENT_SOURCE_DIR}/unofficial-x-plane-sdk-config.cmake.in"
  "${CMAKE_CURRENT_BINARY_DIR}/unofficial-x-plane-sdk-config.cmake"
  INSTALL_DESTINATION "share/unofficial-x-plane-sdk")

install(FILES "${CMAKE_CURRENT_BINARY_DIR}/unofficial-x-plane-sdk-config.cmake"
        DESTINATION "share/unofficial-x-plane-sdk")

install(
  EXPORT xplm-targets
  DESTINATION share/unofficial-x-plane-sdk
  FILE unofficial-x-plane-sdk-targets.cmake
  NAMESPACE unofficial::x-plane-sdk::)
