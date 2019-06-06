#----------------------------------------------------------------
# Generated CMake target import file for configuration "Release".
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "libzippp" for configuration "Release"
set_property(TARGET libzippp APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(libzippp PROPERTIES
  IMPORTED_LINK_INTERFACE_LANGUAGES_RELEASE "CXX"
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/lib/libzippp.lib"
  )

list(APPEND _IMPORT_CHECK_TARGETS libzippp )
list(APPEND _IMPORT_CHECK_FILES_FOR_libzippp "${_IMPORT_PREFIX}/lib/libzippp.lib" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)
