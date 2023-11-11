cmake_minimum_required(VERSION 3.21)
project(xplane-sdk LANGUAGES C CXX)

if(WIN32 OR APPLE)
  add_library(unofficial::xplane-sdk::xplm SHARED IMPORTED)
  if(WIN32)
    set_target_properties(
      unofficial::xplane-sdk::xplm
      PROPERTIES IMPORTED_IMPLIB "${CMAKE_CURRENT_SOURCE_DIR}/Libraries/Win/XPLM_64.lib")
    set_target_properties(
      unofficial::xplane-sdk::xplm PROPERTIES INTERFACE_COMPILE_DEFINITIONS
                                              "-DIBM=1;-DAPL=0;-DLIN=0")
  else()
    set_target_properties(
      unofficial::xplane-sdk::xplm
      PROPERTIES IMPORTED_LOCATION "${CMAKE_CURRENT_SOURCE_DIR}/Libraries/Mac/XPLM.framework/XPLM")
    set_target_properties(
      unofficial::xplane-sdk::xplm PROPERTIES INTERFACE_COMPILE_DEFINITIONS
                                              "-DIBM=0;-DAPL=1;-DLIN=0")
  endif()
else()
  add_library(unofficial::xplane-sdk::xplm INTERFACE IMPORTED)
  set_target_properties(
    unofficial::xplane-sdk::xplm PROPERTIES INTERFACE_COMPILE_DEFINITIONS
                                            "-DIBM=0;-DAPL=0;-DLIN=1")
endif()
set_target_properties(
  unofficial::xplane-sdk::xplm PROPERTIES INTERFACE_INCLUDE_DIRECTORIES
                                          "${CMAKE_CURRENT_SOURCE_DIR}/CHeaders/XPLM")

if(WIN32 OR APPLE)
  add_library(unofficial::xplane-sdk::xpwidgets SHARED IMPORTED)
  if(WIN32)
    set_target_properties(
      unofficial::xplane-sdk::xpwidgets
      PROPERTIES IMPORTED_IMPLIB "${CMAKE_CURRENT_SOURCE_DIR}/Libraries/Win/XPWidgets_64.lib")
  else()
    set_target_properties(
      unofficial::xplane-sdk::xpwidgets
      PROPERTIES IMPORTED_LOCATION
                 "${CMAKE_CURRENT_SOURCE_DIR}/Libraries/Mac/XPWidgets.framework/XPWidgets")
  endif()
else()
  add_library(unofficial::xplane-sdk::xpwidgets INTERFACE IMPORTED)
endif()
set_target_properties(
  unofficial::xplane-sdk::xpwidgets PROPERTIES INTERFACE_LINK_LIBRARIES
                                               "unofficial::xplane-sdk::xplm")
set_target_properties(
  unofficial::xplane-sdk::xpwidgets
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
            $<INSTALL_INTERFACE:include/xplane-sdk/Wrappers>)

target_link_libraries(xplm_cpp PUBLIC unofficial::xplane-sdk::xplm
                                      unofficial::xplane-sdk::xpwidgets)

install(
  TARGETS xplm_cpp
  EXPORT xplm-targets
  ARCHIVE DESTINATION lib)

file(GLOB HEADERS "${CMAKE_CURRENT_LIST_DIR}/CHeaders/XPLM/*.h")
install(FILES ${HEADERS} DESTINATION "include/xplane-sdk/XPLM")

file(GLOB HEADERS "${CMAKE_CURRENT_LIST_DIR}/CHeaders/Widgets/*.h")
install(FILES ${HEADERS} DESTINATION "include/xplane-sdk/Widgets")

file(GLOB HEADERS "${CMAKE_CURRENT_LIST_DIR}/CHeaders/Wrappers/*.h")
install(FILES ${HEADERS} DESTINATION "include/xplane-sdk/Wrappers")

include(CMakePackageConfigHelpers)
configure_package_config_file(
  "${CMAKE_CURRENT_SOURCE_DIR}/unofficial-xplane-sdk-config.cmake.in"
  "${CMAKE_CURRENT_BINARY_DIR}/unofficial-xplane-sdk-config.cmake"
  INSTALL_DESTINATION "share/unofficial-xplane-sdk")

install(FILES "${CMAKE_CURRENT_BINARY_DIR}/unofficial-xplane-sdk-config.cmake"
        DESTINATION "share/unofficial-xplane-sdk")

install(
  EXPORT xplm-targets
  DESTINATION share/unofficial-xplane-sdk
  FILE unofficial-xplane-sdk-targets.cmake
  NAMESPACE unofficial::xplane-sdk::)
