cmake_minimum_required(VERSION 3.21)
project(x-plane LANGUAGES C CXX)

if(WIN32 OR APPLE)
  add_library(unofficial::x-plane::xplm SHARED IMPORTED)
  if(WIN32)
    set_target_properties(
      unofficial::x-plane::xplm
      PROPERTIES IMPORTED_IMPLIB "${CMAKE_CURRENT_SOURCE_DIR}/Libraries/Win/XPLM_64.lib")
    set_target_properties(
      unofficial::x-plane::xplm PROPERTIES INTERFACE_COMPILE_DEFINITIONS
                                              "-DIBM=1;-DAPL=0;-DLIN=0")
  else()
    set_target_properties(
      unofficial::x-plane::xplm
      PROPERTIES IMPORTED_LOCATION "${CMAKE_CURRENT_SOURCE_DIR}/Libraries/Mac/XPLM.framework/XPLM")
    set_target_properties(
      unofficial::x-plane::xplm PROPERTIES INTERFACE_COMPILE_DEFINITIONS
                                              "-DIBM=0;-DAPL=1;-DLIN=0")
  endif()
else()
  add_library(unofficial::x-plane::xplm INTERFACE IMPORTED)
  set_target_properties(
    unofficial::x-plane::xplm PROPERTIES INTERFACE_COMPILE_DEFINITIONS
                                            "-DIBM=0;-DAPL=0;-DLIN=1")
endif()
set_target_properties(
  unofficial::x-plane::xplm PROPERTIES INTERFACE_INCLUDE_DIRECTORIES
                                          "${CMAKE_CURRENT_SOURCE_DIR}/CHeaders/XPLM")

if(WIN32 OR APPLE)
  add_library(unofficial::x-plane::xpwidgets SHARED IMPORTED)
  if(WIN32)
    set_target_properties(
      unofficial::x-plane::xpwidgets
      PROPERTIES IMPORTED_IMPLIB "${CMAKE_CURRENT_SOURCE_DIR}/Libraries/Win/XPWidgets_64.lib")
  else()
    set_target_properties(
      unofficial::x-plane::xpwidgets
      PROPERTIES IMPORTED_LOCATION
                 "${CMAKE_CURRENT_SOURCE_DIR}/Libraries/Mac/XPWidgets.framework/XPWidgets")
  endif()
else()
  add_library(unofficial::x-plane::xpwidgets INTERFACE IMPORTED)
endif()
set_target_properties(
  unofficial::x-plane::xpwidgets PROPERTIES INTERFACE_LINK_LIBRARIES
                                               "unofficial::x-plane::xplm")
set_target_properties(
  unofficial::x-plane::xpwidgets
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
            $<INSTALL_INTERFACE:include>)

target_link_libraries(xplm_cpp PUBLIC unofficial::x-plane::xplm
                                      unofficial::x-plane::xpwidgets)

install(
  TARGETS xplm_cpp
  EXPORT xplm-targets
  ARCHIVE DESTINATION lib)

file(GLOB HEADERS "${CMAKE_CURRENT_LIST_DIR}/CHeaders/XPLM/*.h")
install(FILES ${HEADERS} DESTINATION "include")

file(GLOB HEADERS "${CMAKE_CURRENT_LIST_DIR}/CHeaders/Widgets/*.h")
install(FILES ${HEADERS} DESTINATION "include")

file(GLOB HEADERS "${CMAKE_CURRENT_LIST_DIR}/CHeaders/Wrappers/*.h")
install(FILES ${HEADERS} DESTINATION "include")

include(CMakePackageConfigHelpers)
configure_package_config_file(
  "${CMAKE_CURRENT_SOURCE_DIR}/unofficial-x-plane-config.cmake.in"
  "${CMAKE_CURRENT_BINARY_DIR}/unofficial-x-plane-config.cmake"
  INSTALL_DESTINATION "share/unofficial-x-plane")

install(FILES "${CMAKE_CURRENT_BINARY_DIR}/unofficial-x-plane-config.cmake"
        DESTINATION "share/unofficial-x-plane")

install(
  EXPORT xplm-targets
  DESTINATION share/unofficial-x-plane
  FILE unofficial-x-plane-targets.cmake
  NAMESPACE unofficial::x-plane::)
