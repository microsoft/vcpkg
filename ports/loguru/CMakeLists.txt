cmake_minimum_required(VERSION 3.12)

project(loguru CXX)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_LINK_FLAGS ${CMAKE_CXX_LINK_FLAGS} -lpthread -ldl)

option(INSTALL_HEADERS "Install header files" ON)

set(loguru_headers
  loguru.hpp
)

set(loguru_sources
  loguru.cpp
)

add_library(loguru ${loguru_sources})
target_include_directories(loguru PUBLIC 
                               $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
                               $<INSTALL_INTERFACE:include/loguru>)

set(LOGURU_INCLUDE_INSTALL_DIR include/loguru CACHE PATH "Install directory for headers")
if(INSTALL_HEADERS)
  install(FILES ${loguru_headers} DESTINATION ${LOGURU_INCLUDE_INSTALL_DIR})
endif()

set(INCLUDE_INSTALL_DIR ${LOGURU_INCLUDE_INSTALL_DIR})

include(CMakePackageConfigHelpers)
configure_package_config_file(loguruConfig.cmake.in
              ${CMAKE_CURRENT_BINARY_DIR}/loguruConfig.cmake
              INSTALL_DESTINATION share/loguru
              NO_CHECK_REQUIRED_COMPONENTS_MACRO
              PATH_VARS INCLUDE_INSTALL_DIR)

install(TARGETS loguru
  EXPORT loguruTargets
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)

install(FILES ${CMAKE_CURRENT_BINARY_DIR}/loguruConfig.cmake DESTINATION share/loguru)
install(EXPORT loguruTargets DESTINATION share/loguru)


