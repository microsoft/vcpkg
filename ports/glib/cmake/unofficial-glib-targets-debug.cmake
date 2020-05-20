#----------------------------------------------------------------
# Generated CMake target import file for configuration "Debug".
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "unofficial::glib::glib" for configuration "Debug"
set_property(TARGET unofficial::glib::glib APPEND PROPERTY IMPORTED_CONFIGURATIONS DEBUG)
set_target_properties(unofficial::glib::glib PROPERTIES
  IMPORTED_IMPLIB_DEBUG "${_IMPORT_PREFIX}/debug/lib/glib-2.0.lib"
  IMPORTED_LINK_DEPENDENT_LIBRARIES_DEBUG "unofficial::iconv::libiconv;unofficial::iconv::libcharset"
  IMPORTED_LOCATION_DEBUG "${_IMPORT_PREFIX}/debug/bin/glib-2.0-0.dll"
  )

list(APPEND _IMPORT_CHECK_TARGETS unofficial::glib::glib )
list(APPEND _IMPORT_CHECK_FILES_FOR_unofficial::glib::glib "${_IMPORT_PREFIX}/debug/lib/glib-2.0.lib" "${_IMPORT_PREFIX}/debug/bin/glib-2.0-0.dll" )

# Import target "unofficial::glib::gthread" for configuration "Debug"
set_property(TARGET unofficial::glib::gthread APPEND PROPERTY IMPORTED_CONFIGURATIONS DEBUG)
set_target_properties(unofficial::glib::gthread PROPERTIES
  IMPORTED_IMPLIB_DEBUG "${_IMPORT_PREFIX}/debug/lib/gthread-2.0.lib"
  IMPORTED_LINK_DEPENDENT_LIBRARIES_DEBUG "unofficial::glib::glib"
  IMPORTED_LOCATION_DEBUG "${_IMPORT_PREFIX}/debug/bin/gthread-2.0-0.dll"
  )

list(APPEND _IMPORT_CHECK_TARGETS unofficial::glib::gthread )
list(APPEND _IMPORT_CHECK_FILES_FOR_unofficial::glib::gthread "${_IMPORT_PREFIX}/debug/lib/gthread-2.0.lib" "${_IMPORT_PREFIX}/debug/bin/gthread-2.0-0.dll" )

# Import target "unofficial::glib::gobject" for configuration "Debug"
set_property(TARGET unofficial::glib::gobject APPEND PROPERTY IMPORTED_CONFIGURATIONS DEBUG)
set_target_properties(unofficial::glib::gobject PROPERTIES
  IMPORTED_IMPLIB_DEBUG "${_IMPORT_PREFIX}/debug/lib/gobject-2.0.lib"
  IMPORTED_LINK_DEPENDENT_LIBRARIES_DEBUG "unofficial::glib::gthread;unofficial::glib::glib"
  IMPORTED_LOCATION_DEBUG "${_IMPORT_PREFIX}/debug/bin/gobject-2.0-0.dll"
  )

list(APPEND _IMPORT_CHECK_TARGETS unofficial::glib::gobject )
list(APPEND _IMPORT_CHECK_FILES_FOR_unofficial::glib::gobject "${_IMPORT_PREFIX}/debug/lib/gobject-2.0.lib" "${_IMPORT_PREFIX}/debug/bin/gobject-2.0-0.dll" )

# Import target "unofficial::glib::gmodule" for configuration "Debug"
set_property(TARGET unofficial::glib::gmodule APPEND PROPERTY IMPORTED_CONFIGURATIONS DEBUG)
set_target_properties(unofficial::glib::gmodule PROPERTIES
  IMPORTED_IMPLIB_DEBUG "${_IMPORT_PREFIX}/debug/lib/gmodule-2.0.lib"
  IMPORTED_LINK_DEPENDENT_LIBRARIES_DEBUG "unofficial::glib::glib"
  IMPORTED_LOCATION_DEBUG "${_IMPORT_PREFIX}/debug/bin/gmodule-2.0-0.dll"
  )

list(APPEND _IMPORT_CHECK_TARGETS unofficial::glib::gmodule )
list(APPEND _IMPORT_CHECK_FILES_FOR_unofficial::glib::gmodule "${_IMPORT_PREFIX}/debug/lib/gmodule-2.0.lib" "${_IMPORT_PREFIX}/debug/bin/gmodule-2.0-0.dll" )

# Import target "unofficial::glib::gio" for configuration "Debug"
set_property(TARGET unofficial::glib::gio APPEND PROPERTY IMPORTED_CONFIGURATIONS DEBUG)
set_target_properties(unofficial::glib::gio PROPERTIES
  IMPORTED_IMPLIB_DEBUG "${_IMPORT_PREFIX}/debug/lib/gio-2.0.lib"
  IMPORTED_LINK_DEPENDENT_LIBRARIES_DEBUG "unofficial::glib::glib;unofficial::glib::gmodule;unofficial::glib::gobject"
  IMPORTED_LOCATION_DEBUG "${_IMPORT_PREFIX}/debug/bin/gio-2.0-0.dll"
  )

list(APPEND _IMPORT_CHECK_TARGETS unofficial::glib::gio )
list(APPEND _IMPORT_CHECK_FILES_FOR_unofficial::glib::gio "${_IMPORT_PREFIX}/debug/lib/gio-2.0.lib" "${_IMPORT_PREFIX}/debug/bin/gio-2.0-0.dll" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)
