if (NOT TARGET unofficial::hnswlib::hnswlib)
  get_filename_component(_IMPORT_PREFIX "${CMAKE_CURRENT_LIST_FILE}" PATH)
  get_filename_component(_IMPORT_PREFIX "${_IMPORT_PREFIX}" PATH)
  get_filename_component(_IMPORT_PREFIX "${_IMPORT_PREFIX}" PATH)
  if (_IMPORT_PREFIX STREQUAL "/")
    set(_IMPORT_PREFIX "")
  endif ()

  add_library(unofficial::hnswlib::hnswlib INTERFACE IMPORTED)
  set_target_properties(unofficial::hnswlib::hnswlib PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${_IMPORT_PREFIX}/include")

  set(_IMPORT_PREFIX)
endif ()
