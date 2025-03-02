#----------------------------------------------------------------
# Generated CMake target import file for configuration "Release".
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "my_sample_lib::my_sample_lib" for configuration "Release"
set_property(TARGET my_sample_lib::my_sample_lib APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(my_sample_lib::my_sample_lib PROPERTIES
  IMPORTED_LINK_INTERFACE_LANGUAGES_RELEASE "CXX"
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/lib/my_sample_lib.lib"
  )

list(APPEND _cmake_import_check_targets my_sample_lib::my_sample_lib )
list(APPEND _cmake_import_check_files_for_my_sample_lib::my_sample_lib "${_IMPORT_PREFIX}/lib/my_sample_lib.lib" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)
