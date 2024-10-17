#----------------------------------------------------------------
# Generated CMake target import file for configuration "Debug".
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "box2d::box2d" for configuration "Debug"
set_property(TARGET box2d::box2d APPEND PROPERTY IMPORTED_CONFIGURATIONS DEBUG)
set_target_properties(box2d::box2d PROPERTIES
  IMPORTED_LINK_INTERFACE_LANGUAGES_DEBUG "CXX"
  IMPORTED_LOCATION_DEBUG "${_IMPORT_PREFIX}/debug/lib/box2d.lib"
  )

list(APPEND _cmake_import_check_targets box2d::box2d )
list(APPEND _cmake_import_check_files_for_box2d::box2d "${_IMPORT_PREFIX}/debug/lib/box2d.lib" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)
