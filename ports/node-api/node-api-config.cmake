
find_path(node-api_INCLUDE_DIR NAMES node/node.h REQUIRED)

# NodeJS docs use '#include <js_native_api.h>', not '#include <node/js_native_api.h>' so:
set(node-api_INCLUDE_DIR "${node-api_INCLUDE_DIR}/node")

find_library(node-api_LIBRARY NAMES node)

add_library(node_api INTERFACE)

target_include_directories(node_api INTERFACE
  $<BUILD_INTERFACE:${node-api_INCLUDE_DIR}>
  $<INSTALL_INTERFACE:include>)

target_link_libraries(node_api INTERFACE
  $<BUILD_INTERFACE:${node-api_LIBRARY}>
  $<INSTALL_INTERFACE:lib>)