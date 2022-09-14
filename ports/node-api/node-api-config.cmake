
find_path(node-api_INCLUDE_DIR
  NAMES node.h
  PATHS "${CMAKE_CURRENT_LIST_DIR}/../../include/node"
  NO_DEFAULT_PATH
  REQUIRED)
find_library(node-api_LIBRARY_RELEASE NAMES node PATHS "${CMAKE_CURRENT_LIST_DIR}/../../lib" NO_DEFAULT_PATH REQUIRED)
find_library(node-api_LIBRARY_DEBUG NAMES node PATHS "${CMAKE_CURRENT_LIST_DIR}/../../debug/lib" NO_DEFAULT_PATH REQUIRED)

add_library(node_api INTERFACE)

target_include_directories(node_api INTERFACE
  $<BUILD_INTERFACE:${node-api_INCLUDE_DIR}>
  $<INSTALL_INTERFACE:include>)

target_link_libraries(node_api INTERFACE
  $<BUILD_INTERFACE:$<$<CONFIG:Debug>:${node-api_LIBRARY_DEBUG}>$<$<CONFIG:Release>:${node-api_LIBRARY_RELEASE}>>
  $<INSTALL_INTERFACE:lib>)

# add win_delay_load_hook to TARGET_SOURCES
if(WIN32)
  target_sources(node_api INTERFACE
    $<BUILD_INTERFACE:${CMAKE_CURRENT_LIST_DIR}/../node-api/win_delay_load_hook.cc>
    $<INSTALL_INTERFACE:lib>)
endif()