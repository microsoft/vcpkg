get_filename_component(_prefix "${CMAKE_CURRENT_LIST_DIR}/../.." ABSOLUTE)

# Header lives at: <prefix>/include/ta-lib/ta_libc.h
find_path(talib_INCLUDE_DIR
  NAMES ta-lib/ta_libc.h
  PATHS "${_prefix}/include"
  NO_DEFAULT_PATH
)

# Lib lives at: <prefix>/(debug/)?lib/libta-lib.*
find_library(talib_LIBRARY_RELEASE
  NAMES ta-lib
  PATHS "${_prefix}/lib"
  NO_DEFAULT_PATH
)
find_library(talib_LIBRARY_DEBUG
  NAMES ta-lib
  PATHS "${_prefix}/debug/lib"
  NO_DEFAULT_PATH
)

include(SelectLibraryConfigurations)
select_library_configurations(talib) # sets talib_LIBRARY based on config

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(talib
  REQUIRED_VARS talib_INCLUDE_DIR talib_LIBRARY
)

if(talib_FOUND AND NOT TARGET talib::talib)
  add_library(talib::talib UNKNOWN IMPORTED)
  set_target_properties(talib::talib PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${talib_INCLUDE_DIR}"
  )

  if(talib_LIBRARY_RELEASE)
    set_property(TARGET talib::talib APPEND PROPERTY IMPORTED_CONFIGURATIONS Release)
    set_target_properties(talib::talib PROPERTIES
      IMPORTED_LOCATION_RELEASE "${talib_LIBRARY_RELEASE}"
    )
  endif()

  if(talib_LIBRARY_DEBUG)
    set_property(TARGET talib::talib APPEND PROPERTY IMPORTED_CONFIGURATIONS Debug)
    set_target_properties(talib::talib PROPERTIES
      IMPORTED_LOCATION_DEBUG "${talib_LIBRARY_DEBUG}"
    )
  endif()
endif()
