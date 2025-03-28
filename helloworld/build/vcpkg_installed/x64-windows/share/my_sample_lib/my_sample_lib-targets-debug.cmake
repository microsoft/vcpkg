#----------------------------------------------------------------
# Generated CMake target import file for configuration "Debug".
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "my_sample_lib::my_sample_lib" for configuration "Debug"
set_property(TARGET my_sample_lib::my_sample_lib APPEND PROPERTY IMPORTED_CONFIGURATIONS DEBUG)
set_target_properties(my_sample_lib::my_sample_lib PROPERTIES
  IMPORTED_LINK_INTERFACE_LANGUAGES_DEBUG "CXX"
  IMPORTED_LOCATION_DEBUG "${_IMPORT_PREFIX}/debug/lib/my_sample_lib.lib"
  )

list(APPEND _cmake_import_check_targets my_sample_lib::my_sample_lib )
list(APPEND _cmake_import_check_files_for_my_sample_lib::my_sample_lib "${_IMPORT_PREFIX}/debug/lib/my_sample_lib.lib" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)
