#----------------------------------------------------------------
# Generated CMake target import file for configuration "Debug".
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "libzippp" for configuration "Debug"
set_property(TARGET libzippp APPEND PROPERTY IMPORTED_CONFIGURATIONS DEBUG)
set_target_properties(libzippp PROPERTIES
  IMPORTED_LINK_INTERFACE_LANGUAGES_DEBUG "CXX"
  IMPORTED_LOCATION_DEBUG "${_IMPORT_PREFIX}/debug/lib/libzippp_static.lib"
  )

list(APPEND _IMPORT_CHECK_TARGETS libzippp )
list(APPEND _IMPORT_CHECK_FILES_FOR_libzippp "${_IMPORT_PREFIX}/debug/lib/libzippp_static.lib" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)
