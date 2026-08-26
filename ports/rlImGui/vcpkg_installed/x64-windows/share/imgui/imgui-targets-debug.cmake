#----------------------------------------------------------------
# Generated CMake target import file for configuration "Debug".
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "imgui::imgui" for configuration "Debug"
set_property(TARGET imgui::imgui APPEND PROPERTY IMPORTED_CONFIGURATIONS DEBUG)
set_target_properties(imgui::imgui PROPERTIES
  IMPORTED_LINK_INTERFACE_LANGUAGES_DEBUG "CXX"
  IMPORTED_LOCATION_DEBUG "${_IMPORT_PREFIX}/debug/lib/imguid.lib"
  )

list(APPEND _cmake_import_check_targets imgui::imgui )
list(APPEND _cmake_import_check_files_for_imgui::imgui "${_IMPORT_PREFIX}/debug/lib/imguid.lib" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)
