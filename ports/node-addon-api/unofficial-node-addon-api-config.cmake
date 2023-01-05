include(CMakeFindDependencyMacro)
find_dependency(unofficial-node-api CONFIG)

add_library(unofficial::node-addon-api::node-addon-api IMPORTED INTERFACE)
target_link_libraries(unofficial::node-addon-api::node-addon-api INTERFACE unofficial::node-api::node-api)

set_target_properties(unofficial::node-addon-api::node-addon-api PROPERTIES
  INTERFACE_INCLUDE_DIRECTORIES "${CMAKE_CURRENT_LIST_DIR}/../../include/"
)
