get_filename_component(_IMPORT_PREFIX "${CMAKE_CURRENT_LIST_FILE}" PATH)
get_filename_component(_IMPORT_PREFIX "${_IMPORT_PREFIX}" PATH)
get_filename_component(_IMPORT_PREFIX "${_IMPORT_PREFIX}" PATH)

add_library(vk-bootstrap::vk-bootstrap SHARED IMPORTED)
set_target_properties(vk-bootstrap::vk-bootstrap PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${_IMPORT_PREFIX}/include;${_IMPORT_PREFIX}/include"
)

get_filename_component(_DIR "${CMAKE_CURRENT_LIST_FILE}" PATH)
file(GLOB CONFIG_FILES "${_DIR}/vk-bootstrap-targets-*.cmake")
foreach(f ${CONFIG_FILES})
  include(${f})
endforeach()
