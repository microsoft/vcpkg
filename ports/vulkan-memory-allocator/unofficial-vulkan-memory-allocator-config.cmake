
get_filename_component(_IMPORT_PREFIX "${CMAKE_CURRENT_LIST_FILE}" PATH)
get_filename_component(_IMPORT_PREFIX "${_IMPORT_PREFIX}" PATH)
get_filename_component(_IMPORT_PREFIX "${_IMPORT_PREFIX}" PATH)

add_library(unofficial::vulkan-memory-allocator::vulkan-memory-allocator INTERFACE IMPORTED)
set_target_properties(unofficial::vulkan-memory-allocator::vulkan-memory-allocator PROPERTIES INTERFACE_INCLUDE_DIRECTORIES "${_IMPORT_PREFIX}/include")
set(_IMPORT_PREFIX)
