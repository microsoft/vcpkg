#----------------------------------------------------------------
# Generated CMake target import file for configuration "Release".
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "glfw" for configuration "Release"
set_property(TARGET glfw APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(glfw PROPERTIES
  IMPORTED_IMPLIB_RELEASE "${_IMPORT_PREFIX}/lib/glfw3dll.lib"
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/bin/glfw3.dll"
  )

list(APPEND _cmake_import_check_targets glfw )
list(APPEND _cmake_import_check_files_for_glfw "${_IMPORT_PREFIX}/lib/glfw3dll.lib" "${_IMPORT_PREFIX}/bin/glfw3.dll" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)
