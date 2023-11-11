cmake_minimum_required(VERSION 3.19)
project(xplane-sdk LANGUAGES C CXX)

if(VCPKG_TARGET_IS_WINDOWS OR VCPKG_TARGET_IS_OSX)
  add_library(xplm SHARED IMPORTED)
  add_library(xpwidgets SHARED IMPORTED)
  target_link_libraries(xpwidgets PUBLIC xplm)
endif()

if(VCPKG_TARGET_IS_WINDOWS)
  set_target_properties(
    xplm PROPERTIES IMPORTED_IMPLIB
                    "${CMAKE_CURRENT_SOURCE_DIR}/Libraries/Win/XPLM_64.lib")
  set_target_properties(
    xpwidgets
    PROPERTIES IMPORTED_IMPLIB
               "${CMAKE_CURRENT_SOURCE_DIR}/Libraries/Win/XPWidgets_64.lib")
  target_compile_definitions(xplm PUBLIC
    -DIBM=1
    -DAPL=0
    -DLIN=0
  )
elseif(VCPKG_TARGET_IS_OSX)
  set_target_properties(
    xplm
    PROPERTIES IMPORTED_LOCATION
               "${CMAKE_CURRENT_SOURCE_DIR}/Libraries/Mac/XPLM.framework/XPLM")
  set_target_properties(
    xpwidgets
    PROPERTIES
      IMPORTED_LOCATION
      "${CMAKE_CURRENT_SOURCE_DIR}/Libraries/Mac/XPWidgets.framework/XPWidgets")
  target_compile_definitions(xplm PUBLIC
    -DIBM=0
    -DAPL=1
    -DLIN=0
  )
else()
  add_library(xplm INTERFACE)
  add_library(xpwidgets INTERFACE)
  target_link_libraries(xpwidgets INTERFACE xplm)
  target_compile_definitions(xplm INTERFACE
    -DIBM=0
    -DAPL=0
    -DLIN=1
  )
endif()

target_include_directories(
  xplm INTERFACE $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/CHeaders/XPLM>
                 $<INSTALL_INTERFACE:include/xplane-sdk/XPLM>)

target_include_directories(
  xpwidgets
  INTERFACE $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/CHeaders/Widgets>
            $<INSTALL_INTERFACE:include/xplane-sdk/Widgets>)

add_library(xplm_cpp)

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

target_link_libraries(xplm_cpp PUBLIC xplm xpwidgets)

install(
  TARGETS xplm xpwidgets xplm_cpp
  EXPORT xplm-targets
  ARCHIVE DESTINATION lib
  LIBRARY DESTINATION lib)

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
