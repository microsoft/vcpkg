add_library(hlslpp::hlslpp INTERFACE)
add_library(hlslpp ALIAS hlslpp::hlslpp)

target_include_directories(hlslpp INTERFACE "${CMAKE_CURRENT_LIST_DIR}/../../include/hlslpp")
