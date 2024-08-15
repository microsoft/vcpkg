add_library(hlslpp INTERFACE)
add_library(hlslpp::hlslpp ALIAS hlslpp)

target_include_directories(hlslpp INTERFACE "${CMAKE_CURRENT_LIST_DIR}/../../include/hlslpp")
