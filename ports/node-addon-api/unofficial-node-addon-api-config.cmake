find_package(unofficial-node-api CONFIG REQUIRED)

add_library(unofficial::node-addon-api::node-addon-api INTERFACE)
target_link_libraries(unofficial::node-addon-api::node-addon-api INTERFACE unofficial::node-api::node-api)

find_path(node-addon-api_INCLUDE_DIR
  NAMES napi.h
  PATHS "${CMAKE_CURRENT_LIST_DIR}/../../include/node-addon-api"
  NO_DEFAULT_PATH
  REQUIRED)
set_target_properties(unofficial::node-addon-api::node-addon-api PROPERTIES
  INTERFACE_INCLUDE_DIRECTORIES "${node-addon-api_INCLUDE_DIR}"
)
