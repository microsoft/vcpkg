add_library(unofficial::hlslpp::hlslpp INTERACE IMPORTED)
target_include_directories(unofficial::hlslpp::hlslpp INTERFACE "${CMAKE_CURRENT_LIST_DIR}/../../include/hlslpp")
