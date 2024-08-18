add_library(yatm INTERFACE)
add_library(yatm::yatm ALIAS yatm)

target_include_directories(yatm INTERFACE "${CMAKE_CURRENT_LIST_DIR}/../../include")
