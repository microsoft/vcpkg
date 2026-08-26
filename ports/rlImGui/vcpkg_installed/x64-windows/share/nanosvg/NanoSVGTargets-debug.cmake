#----------------------------------------------------------------
# Generated CMake target import file for configuration "Debug".
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "NanoSVG::nanosvg" for configuration "Debug"
set_property(TARGET NanoSVG::nanosvg APPEND PROPERTY IMPORTED_CONFIGURATIONS DEBUG)
set_target_properties(NanoSVG::nanosvg PROPERTIES
  IMPORTED_LINK_INTERFACE_LANGUAGES_DEBUG "C"
  IMPORTED_LOCATION_DEBUG "${_IMPORT_PREFIX}/debug/lib/nanosvg.lib"
  )

list(APPEND _cmake_import_check_targets NanoSVG::nanosvg )
list(APPEND _cmake_import_check_files_for_NanoSVG::nanosvg "${_IMPORT_PREFIX}/debug/lib/nanosvg.lib" )

# Import target "NanoSVG::nanosvgrast" for configuration "Debug"
set_property(TARGET NanoSVG::nanosvgrast APPEND PROPERTY IMPORTED_CONFIGURATIONS DEBUG)
set_target_properties(NanoSVG::nanosvgrast PROPERTIES
  IMPORTED_LINK_INTERFACE_LANGUAGES_DEBUG "C"
  IMPORTED_LOCATION_DEBUG "${_IMPORT_PREFIX}/debug/lib/nanosvgrast.lib"
  )

list(APPEND _cmake_import_check_targets NanoSVG::nanosvgrast )
list(APPEND _cmake_import_check_files_for_NanoSVG::nanosvgrast "${_IMPORT_PREFIX}/debug/lib/nanosvgrast.lib" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)
