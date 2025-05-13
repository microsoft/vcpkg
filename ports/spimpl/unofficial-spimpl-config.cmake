add_library(unofficial::spimpl::spimpl INTERFACE IMPORTED)

set_target_properties(
  unofficial::spimpl::spimpl
  PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${CMAKE_CURRENT_LIST_DIR}/../../include"
)
