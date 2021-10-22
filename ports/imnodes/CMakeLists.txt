cmake_minimum_required(VERSION 3.8)
project(imnodes CXX)

if(MSVC)
    add_definitions(-D_CRT_SECURE_NO_WARNINGS)
endif()

set(CMAKE_DEBUG_POSTFIX d)

find_package(imgui CONFIG REQUIRED)
get_target_property(IMGUI_INCLUDE_DIRS imgui::imgui
                    INTERFACE_INCLUDE_DIRECTORIES)

add_library(${PROJECT_NAME} "")
add_library(${PROJECT_NAME}::${PROJECT_NAME} ALIAS ${PROJECT_NAME})
target_include_directories(
  ${PROJECT_NAME}
  PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
         $<INSTALL_INTERFACE:include>
  PRIVATE ${IMGUI_INCLUDE_DIRS})

target_sources(${PROJECT_NAME} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/imnodes.cpp
                                       ${CMAKE_CURRENT_SOURCE_DIR}/imnodes.h)

install(
  TARGETS ${PROJECT_NAME}
  EXPORT ${PROJECT_NAME}_target
  ARCHIVE DESTINATION lib
  LIBRARY DESTINATION lib
  RUNTIME DESTINATION bin)

if(NOT IMNODES_SKIP_HEADERS)
  install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/imnodes.h DESTINATION include)
endif()

install(
  EXPORT ${PROJECT_NAME}_target
  NAMESPACE unofficial::${PROJECT_NAME}
  FILE ${PROJECT_NAME}-config.cmake
  DESTINATION share/${PROJECT_NAME})
