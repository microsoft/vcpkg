#----------------------------------------------------------------
# Generated CMake target import file for configuration "Release".
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "NanoSVG::nanosvg" for configuration "Release"
set_property(TARGET NanoSVG::nanosvg APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(NanoSVG::nanosvg PROPERTIES
  IMPORTED_LINK_INTERFACE_LANGUAGES_RELEASE "C"
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/lib/nanosvg.lib"
  )

list(APPEND _cmake_import_check_targets NanoSVG::nanosvg )
list(APPEND _cmake_import_check_files_for_NanoSVG::nanosvg "${_IMPORT_PREFIX}/lib/nanosvg.lib" )

# Import target "NanoSVG::nanosvgrast" for configuration "Release"
set_property(TARGET NanoSVG::nanosvgrast APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(NanoSVG::nanosvgrast PROPERTIES
  IMPORTED_LINK_INTERFACE_LANGUAGES_RELEASE "C"
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/lib/nanosvgrast.lib"
  )

list(APPEND _cmake_import_check_targets NanoSVG::nanosvgrast )
list(APPEND _cmake_import_check_files_for_NanoSVG::nanosvgrast "${_IMPORT_PREFIX}/lib/nanosvgrast.lib" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)
